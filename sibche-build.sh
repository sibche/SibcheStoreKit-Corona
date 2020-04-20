# This script should be runned in mac which have Xcode and Xcode tools installed

mkdir Output
bash ./ios/build.sh ./Output

cp -r ./ios/EmbeddedFrameworks/SibcheStoreKit.framework ./Output/BuiltPlugin/iphone/
cp -r ./ios/EmbeddedFrameworks/SibcheStoreKit.framework ./Output/BuiltPlugin/iphone-sim/

cp ./Corona/sibche/wrapper.lua ./Output/BuiltPlugin/iphone/
cp ./Corona/sibche/wrapper.lua ./Output/BuiltPlugin/iphone-sim/

cd Output/BuiltPlugin/iphone/
tar -czf iphone.tgz libplugin_SibcheStoreKit.a metadata.lua resources wrapper.lua SibcheStoreKit.framework
mv -f iphone.tgz ../../../

cd ../iphone-sim
tar -czf iphone-sim.tgz libplugin_SibcheStoreKit.a metadata.lua resources wrapper.lua SibcheStoreKit.framework
mv -f iphone-sim.tgz ../../../