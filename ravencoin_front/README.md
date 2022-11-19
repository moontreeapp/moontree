# ravencoin_front

Ravencoin mobile app for Android and iOS, using Flutter.

Note that the "back end" is at https://github.com/moontreeapp/ravencoin_back.

## Development

You will need the latest Flutter development kit.

For help getting started with Flutter, view the
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

We recommend installing [fvm](https://fvm.app/docs/getting_started/installation) ("Flutter Version Manager") to ease matching the app's dependencies with your installed version of flutter. (Quick start: `dart pub global activate fvm`).

Next, create an empty directory. It will hold the following projects:

- ravencoin_front
- ravencoin_back
- raven_electrum
- wallet_utils
- reservoir

Then, clone each project inside the empty directory:

```
git clone git@github.com:moontreeapp/ravencoin_front.git
git clone git@github.com:moontreeapp/ravencoin_back.git
git clone git@github.com:moontreeapp/raven_electrum.git
git clone git@github.com:moontreeapp/wallet_utils.git
git clone git@github.com:moontreeapp/reservoir.git
```

Finally, start your Android or IOS emulator, and run the app on your emulator:

```
cd ravencoin_front
fvm flutter run
# (or just `flutter run` if you are managing your own flutter versions)
```
