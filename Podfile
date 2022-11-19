# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
use_frameworks!

def shared_pods
    # Pods for DailyToDoList
    pod 'RealmSwift' , '> 10.0.0'
    pod 'FirebaseAuth' , '> 9.0.0'
end

target 'DailyToDoList' do
  # Comment the next line if you don't want to use dynamic frameworks
  shared_pods
  pod 'FirebaseDatabase' , '> 9.0.0'
  pod 'FirebaseMessaging' , '> 9.0.0'
  pod 'FirebaseAnalytics' , '> 9.0.0'
  pod 'GoogleSignIn' , '> 6.0.0'
  pod 'FSCalendar' , '> 2.0.0'
end

target 'DailyToDoListWidgetExtension' do
  shared_pods
  # Pods for DailyToDoListWidgetExtension
end

target 'DailyToDoListWatchWatchKitExtension' do
  shared_pods
  # Pods for DailyToDoListWidgetExtension
end

target 'DailyToDoListTests' do
  shared_pods
  # Pods for testing
end

target 'DailyToDoListUITests' do
  # Pods for testing
end

