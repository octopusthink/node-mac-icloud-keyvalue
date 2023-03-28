declare module 'node-mac-icloud-keyvalue' {
  type TypeMap = {
    string: string;
    double: number;
    boolean: boolean;
    array: unknown[];
    dictionary: Record<string, unknown>;
  };

  export function getAllValues(): Record<string, TypeMap[keyof TypeMap]>;

  export function getValue<T extends keyof TypeMap>(type: T, key: string): TypeMap[T];

  export function setValue<T extends keyof TypeMap>(type: T, key: string, value: TypeMap[T]);

  export function removeValue(key: string): void;
}
