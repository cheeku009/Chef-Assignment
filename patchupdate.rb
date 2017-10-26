# Cookbook Name:: InstallWindowspatches
# Recipe:: Patchupdates
# Author(s):: SK
#

# Configures Windows Update automatic patches
powershell_script "install-windows-patches" do
  guard_interpreter :powershell_script
  # Set a 2 hour timeout
  timeout 7200
  code <<-EOH
    Write-Host -ForegroundColor Green "Searching for patches (this may take up to 30 minutes or more)..."

    $patchesession = New-Object -com Microsoft.Update.Session
    $patchesearcher = $patchesession.Createpatchesearcher()
    try
    {
      $searchResult =  $patchesearcher.Search("Type='Software' and IsHidden=0 and IsInstalled=0").patches
    }
    catch
    {
      eventcreate /t ERROR /ID 1 /L APPLICATION /SO "Chef-Cookbook" /D "InstallWindowspatches: Update attempt failed."
      $updateFailed = $true
    }

    if(!($updateFailed)) {
      foreach ($updateItem in $searchResult) {
        $patchesToDownload = New-Object -com Microsoft.Update.UpdateColl
        if (!($updateItem.EulaAccepted)) {
          $updateItem.AcceptEula()
        }
        $patchesToDownload.Add($updateItem)
        $Downloader = $patchesession.CreateUpdateDownloader()
        $Downloader.patches = $patchesToDownload
        $Downloader.Download()
        $patchesToInstall = New-Object -com Microsoft.Update.UpdateColl
        $patchesToInstall.Add($updateItem)
        $Title = $updateItem.Title
        Write-host -ForegroundColor Green "  Installing Update: $Title"
        $Installer = $patchesession.CreateUpdateInstaller()
        $Installer.patches = $patchesToInstall
        $InstallationResult = $Installer.Install()
        eventcreate /t INFORMATION /ID 1 /L APPLICATION /SO "Chef-Cookbook" /D "InstallWindowspatches: Installed update $Title."
      }

      if (!($searchResult.Count)) {
        eventcreate /t INFORMATION /ID 999 /L APPLICATION /SO "Chef-Cookbook" /D "InstallWindowspatches: No patches available."
      }
      eventcreate /t INFORMATION /ID 1 /L APPLICATION /SO "Chef-Cookbook" /D "InstallWindowspatches: Done Installing patches."
    }
  EOH
  action :run
end
