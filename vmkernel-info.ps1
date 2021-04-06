### Iterate through vCeners/Hosts to capture NIC Teaming Policies for standard and distributed virtual switches. 
### Author: Bill Hill

##Connect to vCenter
Connect-VIServer -Server '[Replace with your vCenter]' -user 'administrator@vsphere.local' -password '[Replace With Your Password!]'

##Get environment facts/objects
$vcenter = $global:defaultviserver.Name
$clusters = get-cluster 
$vmkernelInfo = $null
$vmkernelInfo = New-Object System.Collections.ArrayList

##iterate through all clusters to get host details
foreach ($cluster in $clusters)
{
    ## Get hosts in the cluster
    $hosts = Get-VMHost -Location $cluster

    ## Iterate through all hosts and gather VMkernel info
    foreach ($esxihost in $hosts)
    {   
        $vds = Get-VDSwitch -vmhost $esxihost 
        $virtualswitches = get-virtualswitch -VMHost $esxihost -Standard
        
        #Process distributed virtual switches
        foreach ($switch in $vds) {
            $vdportgroup = $vds | Get-VDPortgroup 
            $teamingpolicy = $vdportgroup | Get-VDUplinkTeamingPolicy
            #$vmkernelInfo.add($cluster.name, $esxihost.Name, $vds.Name, $vdportgroup.Name, $teamingpolicy.LoadBalancingPolicy, $teamingpolicy.ActiveUplinkPort)

            foreach ($policy in $teamingpolicy)
            {
                $temp = New-Object System.Object
                $temp | Add-Member -MemberType NoteProperty -Name "Switch Type" -Value "Distributed"
                $temp | Add-member -MemberType NoteProperty -name "vCenter" -Value $vcenter
                $temp | Add-Member -MemberType NoteProperty -Name "Cluster" -Value $cluster.Name
                $temp | Add-Member -MemberType NoteProperty -Name "Host" -Value $esxihost.Name
                $temp | Add-Member -MemberType NoteProperty -Name "Virtual Switch" -Value $vds.Name
                $temp | Add-Member -MemberType NoteProperty -Name "Teaming Policy - Load Balancing" -Value $policy.LoadBalancingPolicy
                $temp | Add-Member -MemberType NoteProperty -Name "Teaming Policy - Active Uplink Ports" -Value $policy.ActiveUplinkPort

                $vmkernelInfo.Add($temp) | Out-Null
            }##end foreach teaming policy enumeration
        }##end foreach distributed virtual switches
        
        #Process standard virtual switches
        foreach($virtswitch in $virtualswitches)
        {
                $portgroup = $virtswitch | Get-VirtualPortGroup
                $teampolicy = $portgroup | Get-NicTeamingPolicy

                foreach ($pol in $teampolicy)
                {
                    $temp = New-Object System.Object
                    $temp | Add-Member -MemberType NoteProperty -Name "Switch Type" -Value "Standard"
                    $temp | Add-member -MemberType NoteProperty -name "vCenter" -Value $vcenter
                    $temp | Add-Member -MemberType NoteProperty -Name "Cluster" -Value $cluster.Name
                    $temp | Add-Member -MemberType NoteProperty -Name "Host" -Value $esxihost.Name
                    $temp | Add-Member -MemberType NoteProperty -Name "Virtual Switch" -Value $virtswitch.Name
                    $temp | Add-Member -MemberType NoteProperty -Name "Teaming Policy - Load Balancing" -Value $pol.LoadBalancingPolicy
                    $temp | Add-Member -MemberType NoteProperty -Name "Teaming Policy - Active Uplink Ports" -Value $pol.ActiveUplinkPort
    
                    $vmkernelInfo.Add($temp) | Out-Null

                }##end foreach teaming policy enumeration
        }##end foreach standard switches

    }##end foreach hosts

}##end foreach clusters

$vmkernelInfo | Format-List

