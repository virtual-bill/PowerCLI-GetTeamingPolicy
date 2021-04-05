### Iterate through vCeners/Hosts to capture NIC Teaming Policies
### Author: Bill Hill

##Connect to vCenter
Connect-VIServer -Server 'labvcenter.vb.info' -user 'administrator@vsphere.local' -password '[Replace With Your Password!]'

##Get environment facts/objects
$vcenter = $global:defaultviserver.Name
$clusters = get-cluster 
$vmkernelInfo = New-Object System.Collections.ArrayList

##iterate through all clusters to get host details
foreach ($cluster in $clusters)
{
    ## Get hosts in the cluster
    $hosts = Get-VMHost -Location $cluster

    
    foreach ($esxihost in $hosts)
    {
        ## Iterate through all virtual switches and get the port groups    
        $vds = Get-VDSwitch -vmhost $esxihost 
        
        foreach ($switch in $vds) {
            $vdportgroup = $vds | Get-VDPortgroup 
            $teamingpolicy = $vdportgroup | Get-VDUplinkTeamingPolicy
            #$vmkernelInfo.add($cluster.name, $esxihost.Name, $vds.Name, $vdportgroup.Name, $teamingpolicy.LoadBalancingPolicy, $teamingpolicy.ActiveUplinkPort)

            foreach ($policy in $teamingpolicy)
            {
                $temp = New-Object System.Object
                $temp | Add-member -MemberType NoteProperty -name "vCenter" -Value $vcenter
                $temp | Add-Member -MemberType NoteProperty -Name "Cluster" -Value $cluster.Name
                $temp | Add-Member -MemberType NoteProperty -Name "Host" -Value $esxihost.Name
                $temp | Add-Member -MemberType NoteProperty -Name "Virtual Switch" -Value $vds.Name
                $temp | Add-Member -MemberType NoteProperty -Name "Teaming Policy - Load Balancing" -Value $policy.LoadBalancingPolicy
                $temp | Add-Member -MemberType NoteProperty -Name "Teaming Policy - Active Uplink Ports" -Value $policy.ActiveUplinkPort

                $vmkernelInfo.Add($temp) | Out-Null
            }
        }

    }

}

$vmkernelInfo
