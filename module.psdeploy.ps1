if($ENV:BHProjectName -and $ENV:BHProjectName.Count -eq 1) {
    Deploy OVF-Module {
        By PSGalleryModule {
            FromSource $ENV:BHProjectName
            To PSGallery
            WithOptions @{
                ApiKey = $env:PSGalleryApiKey
            }
        }
    }
}
