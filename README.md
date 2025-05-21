# CaveGame

## Komandos nariai

- Audrius Bertašius
- Paulius Pužas
- Augustas Stankevičius
- Lukas Firantas

## Techninė užduotis

Sukurti žaidimą naudojantis [Godot](https://godotengine.org/) žaidimų variklį, atlikti vienetų testavimą įvairioms žaidime naudojamiems objektams, klasėms, bei atlikti statinę ir našumo analizę. **_FINISH THIS_**

## Architektūra

Žaidimas yra suprogramuotas naudojant Godot žaidimų variklį, kuris naudoja gdsript programavimo kalbą. Pačio žaidimo failai yra sutruktūrizuoti kataloguose pagal tai kokią funkciją jie atlieka.

Kiekvinas katalogas yra pavadintas pagal tai ką saugo ir jame yra visi jam reikalingi resursai, tokie kaip: scenos failai (.tscn); skriptai (.gd); katalogas `assets`, kuriame yra vizualiniai elementai (tekstūros, sprite žemėlapiai).

Pagrindinė žaidimo scena yra `scenes/main` kataloge;

Žaidėjas; goblinas ir kiti subjektai yra saugojami `entities` kataloge;

Ginklai (kardas, lankas) yra `weapons` kataloge;

Struktūros (poilsio zona, pabaigos durys ir kt.) kurias naudojant yra statomas žemėlapis yra `structures` kataloge

Testavimui reikalingi failai saugojami `test` kataloge.

Tekstūros buvo pieštos naudojant [Aseprite](https://www.aseprite.org/) programą, naudojant [aap-splendor128](https://lospec.com/palette-list/aap-splendor128) spalvų paletę.

## Testavimas, jo rezultatai

Text goes here

## Naudotojo dokumentacija

Dokumentaciją galite pasiekti [čia](UserGuide.md)
