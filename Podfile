# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'
	post_install do |pi|
    		pi.pods_project.targets.each do |t|
      			t.build_configurations.each do |config|
        			config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      			end
    		end
	end	

target 'Yobli' do
  # Comment the next line if you don't want to use dynamic frameworks
use_frameworks!

pod 'Parse'
pod 'Parse/FacebookUtils'
pod 'FSCalendar'

# add the Firebase pod for Google Analytics
pod 'Firebase/Analytics'
# add pods for any other desired Firebase products
# https://firebase.google.com/docs/ios/setup#available-pods

pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'Firebase/Database'
pod 'Firebase/Storage'
pod 'Firebase/Messaging'
pod 'Firebase/Firestore'
pod 'IQKeyboardManagerSwift'
pod 'MBProgressHUD'
pod 'MessageKit'
pod 'TwilioVoice', '~> 6.2.1'
pod 'Alamofire'
pod 'KeychainAccess'
pod 'FBSDKCoreKit'
pod 'FBSDKLoginKit'
pod 'FBSDKShareKit'

end
