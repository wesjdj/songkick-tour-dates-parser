$currentPage = 1
$pageCount = 11
$concerts = @()
$artist = "" #Insert Artist Name

While ($currentPage -le $pageCount) {
    $webPage = Get-Content "" #Insert htm file location
    $lineCount = 0
    While ($lineCount -lt $webPage.Count) {
        
        $otherArtists = ""
        $venue = ""
        $city = ""
        $address = ""
        $festival = ""
        
        If ($webPage[$lineCount] -like "*datetime=*") {
            If ($webPage[$lineCount+4] -like "*title*") {
                $date = $webPage[$lineCount+4].split('",â€"')
                $concert = New-Object PSObject
                $niceDate = Get-Date -Date $date[1] -format "yyyy-MM-dd"
                $concert | Add-Member -MemberType NoteProperty -Name "Event Date" -Value $niceDate -Force
                If ($date[3] -like "*day*") {
                    $endDateSplit = $date[3].split(' ')
                    $endDate = "$($endDateSplit[4])-$($endDateSplit[3])-$($endDateSplit[2])"
                    $endDate = Get-Date -Date $endDate -format "yyyy-MM-dd"
                    $concert | Add-Member -MemberType NoteProperty -Name "End Date" -Value $endDate -Force
                }
            }

        }
        If ($webPage[$lineCount] -like "*artists summary*") {
            If ($webPage[$lineCount+2] -like "*$($artist)*") {
                $concert | Add-Member -MemberType NoteProperty -Name "Artist" -Value $artist -Force
                If ($webPage[$lineCount+3] -like "*with*") {
                    $otherArtists = $webPage[$lineCount+3] -split ("with ")
                    $concert | Add-Member -MemberType NoteProperty -Name "Other Artists" -Value $otherArtists[1] -Force
                } ElseIf ($webPage[$lineCount+3] -like "*span*") {
                    $festival = $webPage[$lineCount+3].split("><")
                    $concert | Add-Member -MemberType NoteProperty -Name "Festival" -Value $festival[2] -Force
                }
            } ElseIf ($webPage[$lineCount+3] -like "*$($artist)*") {
                $concert | Add-Member -MemberType NoteProperty -Name "Artist" -Value $artist -Force
                If ($webPage[$lineCount+4] -like "*with*") {
                    $otherArtists = $webPage[$lineCount+4] -split ("with ")
                    $concert | Add-Member -MemberType NoteProperty -Name "Other Artists" -Value $otherArtists[1] -Force
                } ElseIf ($webPage[$lineCount+4] -like "*span*") {
                    $festival = $webPage[$lineCount+3].split("><")
                    $concert | Add-Member -MemberType NoteProperty -Name "Festival" -Value $festival[2] -Force
                }
            }
        }
        If ($webPage[$lineCount] -like "*location*") {
            If ($webPage[$lineCount+1] -like "*venue-name*") {
                $venue = $webPage[$lineCount+1].split("><")
                If ($venue[4]) {
                    $concert | Add-Member -MemberType NoteProperty -Name "Venue" -Value $venue[4] -Force
                }

                $city = $webPage[$lineCount+4].split("><")
                If ($city[2]) {
                    $concert | Add-Member -MemberType NoteProperty -Name "City" -Value $city[2] -Force
                }

                $address = $webPage[$lineCount+5].split("><")
                If ($address[2]) {
                    $concert | Add-Member -MemberType NoteProperty -Name "Address" -Value $address[2] -Force
                }
            } ElseIf ($webPage[$lineCount+3] -like "*span*") {
                $venue = $webPage[$lineCount+3].split("><")
                If ($venue[2]) {
                    $concert | Add-Member -MemberType NoteProperty -Name "Venue" -Value $venue[2] -Force
                }
            }
                
        }
        If ($webPage[$lineCount] -like "*im-going attendance-action*") {
            $concerts = $concerts + $concert
        }
        $lineCount++
    }
    $currentPage++
}

$concerts = $concerts | Sort-Object -Property "Event Date","Venue" -Unique
