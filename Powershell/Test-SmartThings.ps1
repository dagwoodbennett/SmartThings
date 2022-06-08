#
# Test-SmartThings.ps1 --- script to get data from SmartThings about all devices for later analysis.
#

# SmartThings Rest API documentation
#    https://developer-preview.smartthings.com/docs/api/public/#tag/Devices
#    https://developer-preview.smartthings.com/docs/devices/health/
#
# SmartThings Requesting Auth Token
#    https://account.smartthings.com/tokens
#

#
# Replace this value with the Auth Token you get from above
#
$auth_token = "Your auth token for devices"

$header_devices = @{
"authorization" = "Bearer $auth_token"
"Accept" = "application/json"
}

$base_uri = "https://api.smartthings.com/v1/devices"
$health_uri = $base_uri + "/{0}/health"
$device_uri = $base_uri + "/{0}"
$deviceStatus_uri = $base_uri + "/{0}/status"

# Get list of devices
$devices = Invoke-RestMethod -Uri $base_uri -Headers $header_devices

$deviceData = @()

$currentDateTime = Get-Date -UFormat "%m/%d/%Y %R"
$date = Get-Date -UFormat "%Y-%m-%d"

foreach ($device in $devices.items)
{
    # Get Health info for specific device
    $health = Invoke-RestMethod -Uri ($health_uri -f $device.deviceId) -Headers $header_devices

    # Get details for specific device
    $deviceDetails = Invoke-RestMethod -Uri ($device_uri -f $device.deviceId) -Headers $header_devices

    # Get status of a specific device
    $deviceStatus = Invoke-RestMethod -Uri ($deviceStatus_uri -f $device.deviceId) -Headers $header_devices

    # Create custom data object with values for later review
    $data = [PSCustomObject]@{
        Name = $deviceDetails.label
        DeviceType = $deviceDetails.deviceTypeName
        NetworkType = $deviceDetails.deviceNetworkType
        Status = $health.state
        LastUpdateDate = $health.lastUpdatedDate
        BatteryLevel = $deviceStatus.components.main.battery.battery.value
        CurrentDateTime = $currentDateTime
    }

    $deviceData += $data
}

# Export data for all devices to CSV file
$deviceData | Export-csv -Path (".\{0}-Smartthings.csv" -f $date) -Append
