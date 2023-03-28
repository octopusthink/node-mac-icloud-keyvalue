{
  "targets": [{
    "target_name": "nsUbiquitousKeyValueStore",
    "sources": [ ],
    "conditions": [
      ['OS=="mac"', {
        "sources": [
          "src/json_formatter.h",
          "src/json_formatter.cc",
          "src/nsUbiquitousKeyValueStore.mm"
        ],
      }]
    ],
    'include_dirs': [
      "<!@(node -p \"require('node-addon-api').include\")"
    ],
    'libraries': [],
    'dependencies': [
      "<!(node -p \"require('node-addon-api').gyp\")"
    ],
    'defines': [ 'NAPI_DISABLE_CPP_EXCEPTIONS' ],
    "xcode_settings": {
      "OTHER_CFLAGS": [
        "-arch x86_64",
        "-arch arm64"
      ],
      "OTHER_CPLUSPLUSFLAGS": ["-std=c++17", "-stdlib=libc++", "-Wextra"],
      "OTHER_LDFLAGS": ["-framework CoreFoundation -framework Cocoa -framework Carbon"],
      "MACOSX_DEPLOYMENT_TARGET": "10.13"
    }
  }]
}
