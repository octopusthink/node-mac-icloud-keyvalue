[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)

# nsUbiquitousKeyValueStore

```js
npm install --save node-mac-icloud-keyvalue
```

`node-mac-icloud-keyvalue` is a native Node.js module that allows you to read/write to [`NSUbiquitousKeyValueStore`](https://developer.apple.com/documentation/foundation/nsubiquitouskeyvaluestore?language=objc). It functions similarly to `UserDefaults` and other simple key/value stores. The advantage to using `NSUbiquitousKeyValueStore` is that it automatically syncs via iCloud for the user account currently signed in to iCloud.

This means you can store things you want synced across all instances of your app, on the Mac and on iOS.

# License

This program is free software; it is distributed under an
[MIT License](https://github.com/octopusthink/node-mac-icloud-keyvalue/blob/master/LICENSE).

This library is based on code in [Shelley Vohr](https://codebyte.re)’s [`node-mac-userdefaults`](https://github.com/codebytere/node-mac-userdefaults). Thanks Shelley! 🙏🏻

---

Copyright (c) 2022 [Octopus Think](https://octopusthink.com)
([Contributors](https://github.com/octopusthink/node-mac-icloud-keyvalue/graphs/contributors)).
