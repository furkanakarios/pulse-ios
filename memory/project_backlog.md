---
name: Uygulama Backlog — Yapılacaklar
description: Kullanıcının test sonrası belirlediği özellik ve düzeltme listesi
type: project
---

Aşağıdaki maddeler Ad Hoc dağıtım testinin ardından belirlendi (2026-04-22):

1. **Widget'tan hızlı su ekleme** — Widget'a basınca uygulamaya gitmeden direkt su kaydı eklenebilsin (WidgetKit Intent / App Intent entegrasyonu gerekli)
2. **Kalori hedefi** — Hedefler kısmına günlük kalori hedefi eklensin (mevcut su ve egzersiz hedeflerinin yanına)
3. **Hedef bildirim saati ayarı** — Günün belirli saatlerinde su, egzersiz ve kalori hedefine ne kadar kaldığını gösteren bildirim; saati kullanıcı belirleyebilsin
4. **Hatırlatıcılara kalori eklenmesi** — Mevcut su ve egzersiz hatırlatıcılarının yanına kalori hatırlatıcısı da eklensin
5. **Widget küçük boyut layout sorunu** — Small widget'ta 2 bilgi üst üste biniyor, küçük boyut için ayrı layout düzenlenecek

**Why:** Kullanıcı uygulamayı test etti, gerçek kullanımda fark edilen eksiklikler.
**How to apply:** Her maddeyi ayrı bir geliştirme adımı olarak ele al, önceliklendirmeyi kullanıcıyla birlikte yap.
