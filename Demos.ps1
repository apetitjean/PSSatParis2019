# Mise en place des prérequis de la démo
# Démarrer Hugo
cd C:\Hugo_Websites\test3\
hugo server

# Demo 1
# Téléchargement de la page sous forme de flux texte
$result = Invoke-RestMethod -Uri http://localhost:1313/ -Method Get
$result | Out-File -FilePath C:\temp\PSSaturday2019\demopage.html -encoding UTF8
code C:\temp\PSSaturday2019\demopage.html

# Récupération du titre de la page
$regex = '<h1 class="animated fadeInUp text-uppercase">(.*)<\/h1>'
$regex2 = '<h1 class="animated fadeInUp text-uppercase">([^<\/h1>]+)<\/h1>'
$result -match $regex2
# Affiche la capture (si $matches vaut Vrai)
$matches[1]

# Récupération du 2e paragraphe "ABOUT US"
$regex = '<p>(.+)<\/p>'
[regex]::Matches($result,$regex)[1].groups[1].Value 


# Demo 2 - Idem Demo1 mais cette fois en utilisant HAP
# Installation à partir de la nuget gallery
Register-PackageSource -Name nugetGallery -Location https://www.nuget.org/api/v2 -Trusted -Provider NuGet -force
Find-Package -Source nugetGallery -Name HtmlAgilityPack
# Update-Module packagemanagement
Save-Package -Name HtmlAgilityPack -RequiredVersion 1.11.16 -Path C:/temp/PSSaturday2019 -Source nugetGallery
Rename-Item C:\temp\PSSaturday2019\HtmlAgilityPack.1.11.16.nupkg HtmlAgilityPack.1.11.16.zip
Expand-Archive C:\temp\PSSaturday2019\htmlagilitypack.1.11.16.zip C:\temp\PSSaturday2019\HAP

# Chargement de la DLL HAP
#Add-Type -Path C:\temp\PSSaturday2019\HAP\lib\Net45\HtmlAgilityPack.dll
Add-Type -Path C:\temp\PSSaturday2019\HAP\lib\netstandard2.0\HtmlAgilityPack.dll

# Instanciation de la classe
$htmlDoc = New-Object HtmlAgilityPack.HtmlDocument

# Chargement de la page Web à scraper
$page = Invoke-RestMethod -Uri http://localhost:1313/index.html -Method Get
$htmldoc.loadhtml($page)

# Récupération du titre de la page
$XPath = '/html/body/section[1]/div/div/div/div/h1'
$htmlDoc.DocumentNode.SelectNodes($XPath).InnerText

# Récupération du 2e paragraphe "ABOUT US"
$XPath = '/html/body/section[2]/div/div/div[1]/div/p'
$htmlDoc.DocumentNode.SelectNodes($XPath).InnerText


# Demo 3 - Module LBC
New-Item -Path C:\temp\PSSaturday2019\demo2 -Type Directory -force
cd C:\temp\PSSaturday2019\demo2

# Installation du module depuis GitHub
git clone https://github.com/apetitjean/LeBonCoin.git

# Chargement du module
Import-Module C:\temp\PSSaturday2019\demo\LeBonCoin\LBC.psd1 -Verbose

$mySearch = @{
    MotsCles = 'Ampli guitare'
    Categorie = 'instruments_de_musique'
    TitreUniquement = $true
    ParticuliersOuPros = 'Tous'
    prixMin = 100
    prixMax = 300
    Region = 'Ile-De-France'
}
Get-LBCURI @mySearch
$LBCURI = Get-LBCURI -MotsCles 'ampli guitare' -Categorie instruments_de_musique  -ParticuliersOuPros Tous -Region Ile-De-France -PrixMax 250

$annonces = Get-LBCAnnonce @mySearch
$annonces = Get-LBCAnnonce -URI $LBCURI