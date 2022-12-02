# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
use_frameworks!

def shared_pods
    # Pods for TodayTODO
    pod 'RealmSwift' , '> 10.0.0'
    pod 'FirebaseAuth' , '> 9.0.0'
    pod 'GoogleUtilities'
end

target 'TodayTODO' do
  # Comment the next line if you don't want to use dynamic frameworks
  shared_pods
  pod 'FirebaseDatabase' , '> 9.0.0'
  pod 'FirebaseMessaging' , '> 9.0.0'
  pod 'FirebaseAnalytics' , '> 9.0.0'
  pod 'GoogleSignIn' , '> 6.0.0'
  pod 'FSCalendar' , '> 2.0.0'
end

target 'TodayTODOWidgetExtension' do
  shared_pods
  # Pods for TodayTODOWidgetExtension
end

target 'TodayTODOWatchWatchKitExtension' do
  shared_pods
  # Pods for TodayTODOWatchWatchKitExtension
end

target 'TodayTODOTests' do
  shared_pods
  # Pods for testing
end

target 'TodayTODOUITests' do
  # Pods for testing
end

