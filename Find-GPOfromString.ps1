#############################################################################
# Author  : Tyler Cox
#
# Version : 1.0
# Created : 11/15/2021
# Modified : 
#
# Purpose : This script will search GPOs for a specified string
#
# Requirements: A computer with Active Directory Admin Center (ADAC) installed and a 
#               user account with enough privileges 
#             
# Change Log: Ver 1.0 - Initial release
#
#############################################################################

Function Find-GPOfromString
    {
        [cmdletbinding()]
        param(
            [parameter(
                Mandatory = $true,
                ValueFromPipeline = $false)]
                [string]$string, #String we want to search for
            [parameter(
                Mandatory = $false,
                ValueFromPipeline = $false)]
                [string]$DomainName = $env:USERDNSDOMAIN, #Get the domain we are searching in based off the user's current domain
            [parameter(
                Mandatory = $false,
                ValueFromPipeline = $false)]
                [string[]]$MatchedGPOList = @()
            )
            
        
        #Get all GPOs in the domain 
        write-host "Getting all the GPOs in $DomainName" 
        try 
            {
                Import-Module grouppolicy -ErrorAction Stop #Import Group Policy Module 
            }
        catch 
            {
                Write-Host "ERROR! Cannot import Group Policy module! Please make sure ADAC is installed!" -ForegroundColor Red
                Exit
            }
        try 
            {
                $AllGPOs = Get-GPO -All -Domain $DomainName -ErrorAction Stop #Pull all GPOs
            }
        catch 
            {   
                Write-Host "ERROR! Cannot extract Group Policies from the domain! make sure you are running this with enough permissions!" -ForegroundColor Red
                Exit
            }
        

        #Inspect each GPO's XML for the string 
        Write-Host "Beginning search.." 
        foreach ($gpo in $AllGPOs) 
            { 
                $report = Get-GPOReport -Guid $gpo.Id -ReportType Xml 
                if ($report -match $string) 
                    { 
                        write-host "Successful match in: $($gpo.DisplayName)" -foregroundcolor "Green"
                        $MatchedGPOList += "$($gpo.DisplayName)"
                    } 
                else 
                    { 
                        Write-Host "No match in: $($gpo.DisplayName)" 
                    } 
            } 


        write-host "Results: "
        foreach ($match in $MatchedGPOList) 
            { 
                write-host "Match found in: $($match)"
            }
    }
