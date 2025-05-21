## Testavimas
Šiame dokumente aprašyta mūsų naudota testavimo metodologija bei įrankiai, naudoti testų formavimui. Testavimo tikslas buvo užtikrinti žaidimo stabilumą bei veikimo greitį, naudojant automatizuotus vienetų testus, rankinį testavimą bei statinę kodo analizę.

## Vienetų testai (unit tests)
Vienetų testai skirti išbandyti specifines žaidimo funkcijas, ar pavienios funkcijos veikia tinkamai įvairiuose scenarijuose.
Šie testai sukurti naudojant *Godot* inetgruotą **GUT** (*Godot Unit Test*) sistemą. Šių testų pavyzdžiai randami `/CaveGame/tests/unit/`. Patys testai parašyti failuose su `.gd` pabaiga, ten juos ir galima išvysti.
Šiuos testus paleisti galima atidarius *Godot*, įsitikinus, kad **GUT** yra instaliuotas ir tinkamai sukonfiguruotas, tuomet atidarius **GUT** langą galima paspausti `Run All` mygtuką, kuris paleis visus testus ir parodys rezultatus. Kai kurių testų rezultatai pateikiami žemiau. 

![image](https://github.com/user-attachments/assets/5bbcc173-7c47-4f65-a7f0-cbe3ea58bfd1)

![image](https://github.com/user-attachments/assets/bb98a6d8-f958-4f7c-8237-c34886f111a0)

![image](https://github.com/user-attachments/assets/33c08979-1769-4f9d-b896-20c813fd053a)

![image](https://github.com/user-attachments/assets/69bb6229-63a6-4fea-a539-a72626405819)

Galutiniai rezultatai pateikiami žemiau:

![image](https://github.com/user-attachments/assets/53b79d00-6e3a-4e6f-b259-b238371eae13)

Galime pastebėti, jog kai kurie vienetų testai - ypač tie, kurie yra susiję su žaidėjo atakos funckija (tiksliau su lanko atakos funckija) nepraeina patikros. Ši finkcija buvo atnaujinta paskutiniojo sprinto metu, o susiję testai nebuvo atnaujinti. Šios funkcijos buvo ištestuotos rankiniu būdu ir veikė tinkamai.

## Integracijos testai
Integracijos testai buvo naudojami patikrinti kelių sistemų tarpusavį veikimą, pavyzdžiui žaidėjo įvesčių ir preišų elgseną ar brangakmenių surinkimą ir UI atnaujinimą.

Pagrindiniai testai aprėpia susidūrimų aptikimą (*collision detection*), žalos vykdymą, priešo (goblino) ir žaidėjo sąveiką bei mirties, iškritus iš pasaliuo atvejį, tačiau jų buvo ir daugiau.
Integracijos testai taip pat tikrino UI atnaujinimą kuomet žaidėjas patiria žalą, surenka brangakmenius ar atidaro pagrindinį meniu.

Šie testai buvo atlikti tiek vykdant testavimo kodą, tiek rankiniu būdu.

## Greitaveikos testai
Stebėjome kadrų dažnį (*framerate*), scenarijaus vykdymo ir scenų įkėlimo laikus, kad užtikrintume sklandžią žaidimo patirtį, ypač didesniuose kambariuose ir zonose su didesniu kiekiu priešų.
Naudojome integruotą Godot *profiler* įrankį, sukūrėme ekstremalius scenarijus su šimtais ar tūkstančiais bandymo objektų (*tam naudojome goblinus*), kad patikrintume žaidimo našumą ekstremaliomis sąlygomis.

Rezultatai:
- Stabilus 60 FPS įprastomis sąlygomis (60 FPS riba pasiekiama dėl V-sync, jei jis išjungtas, FPS gali siekti net 1500 ar net daugiau, priklausomai nuo naudojamos sistemos).
- Pastebimas FPS kritimas ekstremaliomis sąlygomis, reikšmingas kadrų dažnio sumažėjimas, kai ekrane yra daugiau nei 100 goblinų.

## Rankinis testavimas
Žaidimo kūrimo metu komandos nariai atliko rankinius žaidimo bandymus, siekdami nustatyti:
- Vizualines klaidas (ne taip sudėliotus blokelius ir pan.)
- Susidūrimo problemas (ar įmanoma iškristi iš pasaulio ten, kur neturėtų būti įmanoma)
- Vartotojo sąsajos problemas

Problemos buvo fiksuojamos naudojant Jira ir išspręstos kito sprinto metu.

## Statinė kodo analizė
Siekdami palaikyti kodo kokybę ir sumažinti klaidų skaičių, naudojome integruotą *Godot* **gdtoolkit** ir periodiškai peržiūrėjome kodą, atsižvelgdami į:
- Nepasiekiamus kintamuosius
- Nenaudojamą kodą
- Stiliaus nuoseklumą

## Rezultatai
Atlikti testai parodė, jog žaidimas pakankamai stabilus, bei veikia tinkamai normaliomis sąlygomis.
