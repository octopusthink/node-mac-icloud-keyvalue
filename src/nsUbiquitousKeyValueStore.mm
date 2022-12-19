#include <napi.h>

// Apple APIs
#import <Foundation/Foundation.h>

#include "json_formatter.h"

/* HELPER FUNCTIONS */

Napi::Array NSArrayToNapiArray(Napi::Env env, NSArray *array);
Napi::Object NSDictionaryToNapiObject(Napi::Env env, NSDictionary *dict);
NSArray *NapiArrayToNSArray(Napi::Array array);
NSDictionary *NapiObjectToNSDictionary(Napi::Object object);

// Converts a std::string to an NSString.
NSString *ToNSString(const std::string &str) {
  return [NSString stringWithUTF8String:str.c_str()];
}

// Converts a NSArray to a Napi::Array.
Napi::Array NSArrayToNapiArray(Napi::Env env, NSArray *array) {
  if (!array)
    return Napi::Array::New(env, 0);

  size_t length = [array count];
  Napi::Array result = Napi::Array::New(env, length);

  for (size_t idx = 0; idx < length; idx++) {
    id value = array[idx];
    if ([value isKindOfClass:[NSString class]]) {
      result[idx] = std::string([value UTF8String]);
    } else if ([value isKindOfClass:[NSNumber class]]) {
      const char *objc_type = [value objCType];
      if (strcmp(objc_type, @encode(BOOL)) == 0 ||
          strcmp(objc_type, @encode(char)) == 0) {
        result[idx] = [value boolValue];
      } else if (strcmp(objc_type, @encode(double)) == 0 ||
                 strcmp(objc_type, @encode(float)) == 0) {
        result[idx] = [value doubleValue];
      } else {
        result[idx] = [value intValue];
      }
    } else if ([value isKindOfClass:[NSArray class]]) {
      result[idx] = NSArrayToNapiArray(env, value);
    } else if ([value isKindOfClass:[NSDictionary class]]) {
      result[idx] = NSDictionaryToNapiObject(env, value);
    } else {
      result[idx] = std::string([[value description] UTF8String]);
    }
  }

  return result;
}

// Converts a Napi::Object to an NSDictionary.
NSDictionary *NapiObjectToNSDictionary(Napi::Value value) {
  std::string json;
  if (!JSONFormatter::Format(value, &json))
    return nil;

  NSData *jsonData = [NSData dataWithBytes:json.c_str() length:json.length()];
  id obj = [NSJSONSerialization JSONObjectWithData:jsonData
                                           options:0
                                             error:nil];

  return [obj isKindOfClass:[NSDictionary class]] ? obj : nil;
}

// Converts a Napi::Array to an NSArray.
NSArray *NapiArrayToNSArray(Napi::Array array) {
  NSMutableArray *mutable_array =
      [NSMutableArray arrayWithCapacity:array.Length()];

  for (size_t idx = 0; idx < array.Length(); idx++) {
    Napi::Value val = array[idx];

    if (val.IsNumber()) {
      NSNumber *wrappedInt = [NSNumber numberWithInt:val.ToNumber()];
      [mutable_array addObject:wrappedInt];
    } else if (val.IsBoolean()) {
      NSNumber *wrappedBool = [NSNumber numberWithBool:val.ToBoolean()];
      [mutable_array addObject:wrappedBool];
    } else if (val.IsString()) {
      const std::string str = (std::string)val.ToString();
      [mutable_array addObject:ToNSString(str)];
    } else if (val.IsArray()) {
      Napi::Array sub_array = val.As<Napi::Array>();

      if (NSArray *ns_arr = NapiArrayToNSArray(sub_array)) {
        [mutable_array addObject:ns_arr];
      }
    } else if (val.IsObject()) {
      if (NSDictionary *dict = NapiObjectToNSDictionary(val)) {
        [mutable_array addObject:dict];
      }
    }
  }

  return mutable_array;
}

// Converts an NSDictionary to a Napi::Object.
Napi::Object NSDictionaryToNapiObject(Napi::Env env, NSDictionary *dict) {
  Napi::Object result = Napi::Object::New(env);

  if (!dict) {
    return result;
  }

  for (id key in dict) {
    const std::string str_key =
        [key isKindOfClass:[NSString class]]
            ? std::string([key UTF8String])
            : std::string([[key description] UTF8String]);

    id value = [dict objectForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
      result.Set(str_key, std::string([value UTF8String]));
    } else if ([value isKindOfClass:[NSNumber class]]) {
      const char *objc_type = [value objCType];

      if (
        strcmp(objc_type, @encode(BOOL)) == 0 ||
        strcmp(objc_type, @encode(char)) == 0
      ) {
        result.Set(str_key, [value boolValue]);
      } else if (
        strcmp(objc_type, @encode(double)) == 0 ||
        strcmp(objc_type, @encode(float)) == 0
      ) {
        result.Set(str_key, [value doubleValue]);
      } else {
        result.Set(str_key, [value intValue]);
      }
    } else if ([value isKindOfClass:[NSArray class]]) {
      result.Set(str_key, NSArrayToNapiArray(env, value));
    } else if ([value isKindOfClass:[NSDictionary class]]) {
      result.Set(str_key, NSDictionaryToNapiObject(env, value));
    } else {
      result.Set(str_key, std::string([[value description] UTF8String]));
    }
  }

  return result;
}

/* EXPORTED FUNCTIONS */

// Returns all NSUbiquitousKeyValueStore for the current user.
Napi::Object GetAllValues(const Napi::CallbackInfo &info) {
  NSUbiquitousKeyValueStore *defaults = [&]() {
    return [NSUbiquitousKeyValueStore defaultStore];
  }();

  NSDictionary *all_defaults = [defaults dictionaryRepresentation];
  return NSDictionaryToNapiObject(info.Env(), all_defaults);
}

// Returns the value of 'key' in NSUbiquitousKeyValueStore for a specified type.
Napi::Value GetValue(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();

  const std::string type = (std::string)info[0].ToString();
  const std::string key = (std::string)info[1].ToString();

  NSUbiquitousKeyValueStore *defaults = [&]() {
    return [NSUbiquitousKeyValueStore defaultStore];
  }();

  NSString *default_key = [NSString stringWithUTF8String:key.c_str()];

  if (type == "string") {
    NSString *s = [defaults stringForKey:default_key];
    return Napi::String::New(env, s ? std::string([s UTF8String]) : "");
  } else if (type == "boolean") {
    bool b = [defaults boolForKey:default_key];
    return Napi::Boolean::New(env, b ? b : false);
  } else if (type == "double") {
    float f = [defaults doubleForKey:default_key];
    return Napi::Number::New(env, f ? f : 0);
  } else if (type == "array") {
    NSArray *array = [defaults arrayForKey:default_key];
    return NSArrayToNapiArray(env, array);
  } else if (type == "dictionary") {
    NSDictionary *dict = [defaults dictionaryForKey:default_key];
    return NSDictionaryToNapiObject(env, dict);
  } else {
    return env.Null();
  }
}

// Sets the value for 'key' in NSUbiquitousKeyValueStore.
void SetValue(const Napi::CallbackInfo &info) {
  const std::string type = (std::string)info[0].ToString();
  const std::string key = (std::string)info[1].ToString();
  NSString *default_key = ToNSString(key);

  NSUbiquitousKeyValueStore *defaults = [&]() {
    return [NSUbiquitousKeyValueStore defaultStore];
  }();

  if (type == "string") {
    const std::string value = (std::string)info[2].ToString();
    [defaults setObject:ToNSString(value) forKey:default_key];
  } else if (type == "boolean") {
    bool value = info[2].ToBoolean();
    [defaults setBool:value forKey:default_key];
  } else if (type == "float" || type == "integer" || type == "double") {
    double value = info[2].ToNumber().DoubleValue();
    [defaults setDouble:value forKey:default_key];
  } else if (type == "array") {
    Napi::Array array = info[2].As<Napi::Array>();

    if (NSArray *ns_arr = NapiArrayToNSArray(array)) {
      [defaults setObject:ns_arr forKey:default_key];
    }
  } else if (type == "dictionary") {
    Napi::Value value = info[2].As<Napi::Value>();

    if (NSDictionary *dict = NapiObjectToNSDictionary(value)) {
      [defaults setObject:dict forKey:default_key];
    }
  }
}

// Removes the value for 'key' in NSUbiquitousKeyValueStore.
void RemoveValue(const Napi::CallbackInfo &info) {
  const std::string key = (std::string)info[0].ToString();
  NSString *default_key = ToNSString(key);

  NSUbiquitousKeyValueStore *defaults = [&]() {
    return [NSUbiquitousKeyValueStore defaultStore];
  }();

  [defaults removeObjectForKey:default_key];
}

// Initializes all functions exposed to JS.
Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports.Set(Napi::String::New(env, "getAllValues"),
              Napi::Function::New(env, GetAllValues));
  exports.Set(Napi::String::New(env, "getValue"),
              Napi::Function::New(env, GetValue));
  exports.Set(Napi::String::New(env, "setValue"),
              Napi::Function::New(env, SetValue));
  exports.Set(Napi::String::New(env, "removeValue"),
              Napi::Function::New(env, RemoveValue));

  return exports;
}

NODE_API_MODULE(defaults, Init)
