const nsUbiquitousKeyValueStore = require('bindings')('nsUbiquitousKeyValueStore.node');

const VALID_TYPES = ['string', 'double', 'boolean', 'array', 'dictionary'];

function getAllValues() {
  return nsUbiquitousKeyValueStore.getAllValues.call(this);
}

function getValue(type, key) {
  if (!VALID_TYPES.includes(type)) {
    throw new TypeError(`${type} must be one of ${VALID_TYPES.join(', ')}`);
  }

  return nsUbiquitousKeyValueStore.getValue.call(this, type, key);
}

function setValue(type, key, value) {
  if (!VALID_TYPES.includes(type)) {
    throw new TypeError(`${type} must be one of ${VALID_TYPES.join(', ')}`);
  }

  const isFloatOrDouble = (n) => !isNaN(parseFloat(n));
  const isObject = (o) => Object.prototype.toString.call(o) === '[object Object]';

  if (type === 'string' && typeof value !== 'string') {
    throw new TypeError('value must be a valid string');
  } else if (type === 'double' && !isFloatOrDouble(value) && !Number.isInteger(value)) {
    throw new TypeError('value must be a valid double or integer');
  } else if (type === 'boolean' && typeof value !== 'boolean') {
    throw new TypeError('value must be a valid boolean');
  } else if (type === 'array' && !Array.isArray(value)) {
    throw new TypeError('value must be a valid array');
  } else if (type == 'dictionary' && !isObject(value)) {
    throw new TypeError('value must be a valid dictionary');
  }

  return nsUbiquitousKeyValueStore.setValue.call(this, type, key, value);
}

function removeValue(key) {
  return nsUbiquitousKeyValueStore.removeValue.call(this, key);
}

module.exports = {
  getAllValues,
  getValue,
  setValue,
  removeValue,
};
