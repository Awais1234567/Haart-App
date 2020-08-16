# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Haart App' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

pod 'QuickBlox', '~> 2.17.4'
pod 'Quickblox-WebRTC', '~> 2.7.4'

pod "ScaledVisibleCellsCollectionView"

pod 'MessageInputBar'
pod 'MessageInputBar/AttachmentManager'
pod 'MessageInputBar/AutocompleteManager'


pod 'Lightbox'
pod 'FBSDKCoreKit'
pod 'FBSDKLoginKit'
pod 'FBSDKShareKit'
pod 'FAPaginationLayout'
pod 'TTSegmentedControl', '~>0.4.6'
pod 'GoogleMaps'
pod 'GooglePlaces'
  # Pods for Haart App
pod 'DropDown'
pod 'MessageKit', '0.13.1'
pod 'InputBarAccessoryView', '4.2.2'
pod "DSCircularCollectionView"
pod 'IQKeyboardManagerSwift'
pod 'RangeSeekSlider'
pod 'PopupDialog', '~> 1.1'
pod 'ZLSwipeableView'
pod "ViewAnimator"
pod 'SwiftMessages'
pod 'DOButton'
pod 'DateTimePicker'
pod 'NotificationView'
pod 'YPImagePicker'
pod 'Firebase/Core'
pod 'Firebase/Analytics'
pod 'Firebase/DynamicLinks'
pod 'Firebase/Auth'
pod 'Firebase/Database'
pod 'Firebase/Storage'
pod 'GoogleSignIn'
pod 'Firebase/Firestore'
pod 'SVProgressHUD'
pod 'Alamofire'
pod 'Firebase/Messaging'
pod 'CountryPickerView'
pod 'SDWebImage', '~> 5.0'
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          if target.name == 'MessageKit'
              target.build_configurations.each do |config|
                  config.build_settings['SWIFT_VERSION'] = '4.0'
              end
          end
      end
  end
end
