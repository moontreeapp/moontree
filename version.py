'''
updates the version numbers in the build files according to our design

simply run the script with the name of the build you wish to increment
and it will increment the version number in the ios/Flutter/Generate.xcconfig
file and the android/local.properties file respective to the specified platform.

once modifications are made to the build files, the script will also save
it locally to the version file.

if you wish to only view the version, simply add no flags
if you wish to increment only the build number, simply add the -b flag
if you wish to increment the patch number and build number, simply add the -p flag
if you wish to increment the minor number and build number, simply add the --minor flag
if you wish to increment the major number and build number, simply add the --major flag
if you wish to specify the entire version, simply add the --set flag


examples: 

> python version.py ios
1.4.1+13

> python version.py android 
1.0.1+2

> python version.py ios -b
1.4.1+13 -> 1.4.1+14
saved!

> python version.py android -p 
1.0.1+2 -> 1.0.2+3
saved!

> python version.py android --minor
1.0.1+3 -> 1.1.0+4
saved!

> python version.py android --set 1.2.3+4
1.1.0+4 -> 1.2.3+4
saved!
'''


def user():
    ''' if you want to ask the user for input... '''
    import argparse
    parser = argparse.ArgumentParser()
    # parser.add_argument('-o', "--opts",)
    parser.add_argument('-b', "--build", default=False,
                        help="increments the build number")
    parser.add_argument('-p', "--patch", default=False,
                        help="increments the patch number")
    parser.add_argument('-n', "--minor", default=False,
                        help="increments the minor number")
    parser.add_argument('-j', "--major", default=False,
                        help="increments the major number")
    args = parser.parse_args()
    if args.patch or args.minor or args.major:
        args.build = True
    # do the thing...


class client_back():
    ''' if you want to look up the version from the ravencoin repo... '''

    def __init__(self):
        self.existingVersion = ''
        self.existingBuild = ''
        self.newVersion = ''
        self.newBuild = ''
        self.existingVersions = []
        self.newVersions = []
        self.versionLocation = 'client_back/lib/version.dart'
        self.iosLocation = 'client_front/ios/Flutter/Generated.xcconfig'
        self.androidLocation = 'client_front/android/local.properties'

    def __call__(self):
        import json
        with open(self.versionLocation, mode='r') as f:
            versions = (f
                        .read()
                        .split('const VERSIONS = ')[1]
                        .split(';')[0]
                        .replace("'", '"'))
        with open(self.iosLocation, mode='r') as f:
            ios = f.readlines()
        with open(self.androidLocation, mode='r') as f:
            android = f.readlines()
        self.versions = json.loads(versions)
        ios = self._replaceValues(
            versionName='FLUTTER_BUILD_NAME=',
            buildName='FLUTTER_BUILD_NUMBER=',
            platformName='ios',
            lines=ios)
        android = self._replaceValues(
            versionName='flutter.versionName=',
            buildName='flutter.versionCode=',
            platformName='android',
            lines=android)
        with open(self.iosLocation, mode='w') as f:
            f.writelines(ios)
        with open(self.androidLocation, mode='w') as f:
            f.writelines(android)
        for e, n in zip(self.existingVersions, self.newVersions):
            print(f'{e} -> {n}')

    def _replaceValues(self, versionName, buildName, platformName, lines, version='beta'):

        def replacement(x):
            if x.startswith(versionName):
                self.existingVersion = x.split('=')[1].strip()
                self.newVersion = self.versions[platformName][version].split(
                    '+')[0].split('~')[0]
                return versionName + self.newVersion + '\n'
            elif x.startswith(buildName):
                self.existingBuild = x.split('=')[1].strip()
                self.newBuild = self.versions[platformName][version].split(
                    '+')[1].split('~')[0]
                return buildName + self.newBuild + '\n'
            else:
                return x

        items = [replacement(x) for x in lines]
        self.existingVersions.append(
            self.existingVersion + '+' + self.existingBuild)
        self.newVersions.append(self.newVersion + '+' + self.newBuild)
        return items


if __name__ == '__main__':
    # user()
    client_back()()
