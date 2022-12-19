declare module 'node-mac-icloud-keyvalue' {
  export function getAllValues(): Record<string, unknown>;

  export function getValue(type: 'string', key: string): string;
  export function getValue(type: 'double', key: string): number;
  export function getValue(type: 'boolean', key: string): boolean;
  export function getValue(type: 'array', key: string): unknown[];
  export function getValue(type: 'dictionary', key: string): Record<string, unknown>;

  export function setValue(type: 'string', key: string, value: string): void;
  export function setValue(type: 'double', key: string, value: number): void;
  export function setValue(type: 'boolean', key: string, value: boolean): void;
  export function setValue(type: 'array', key: string, value: any[]): void;
  export function setValue(type: 'dictionary', key: string, value: Record<string, any>): void;

  export function removeValue(key: string): void;
}
