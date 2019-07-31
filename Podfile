source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.0'

use_frameworks!
inhibit_all_warnings!

def commonPods

    #Image caching and async image loading
    pod 'PINRemoteImage'
    
    #UICollectionView and UITablView Helpers
    pod 'Dwifft'
    
    #Linting swift syntax
    pod 'SwiftLint'
end

target 'PersistenceDemo' do
    
    commonPods
    
    target 'PersistenceDemoTests' do
        inherit! :search_paths
    end
end

#updates Acknowledgements.plist
#post_install do | installer |
#    require 'fileutils'
#    FileUtils.cp_r('Pods/Target Support Files/Pods-Next/Pods-PersistenceDemo-Acknowledgements.plist', 'PersistenceDemo/Resources/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
#    FileUtils.cp_r('Pods/Target Support Files/Pods-Next/Pods-PersistenceDemo-Acknowledgements.plist', 'PersistenceDemo/Resources/Acknowledgements.plist', :remove_destination => true)
#end
