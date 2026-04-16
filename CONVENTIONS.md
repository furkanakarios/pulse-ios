# Pulse — Proje Kuralları & Konvansiyonlar

## Git Branching Stratejisi

- `main` — Tamamlanmış phase'leri barındırır. Sadece phase tamamlandığında merge edilir.
- `develop` — Tamamlanmış step'leri barındırır. Her step tamamlandığında buraya merge edilir.
- `feature/phase01-step01` — Her step için açılan geliştirme branch'i.

### Branch Akışı

```
feature/phaseXX-stepYY
        ↓ (step tamamlanınca)
    develop
        ↓ (tüm phase tamamlanınca)
      main
```

### Branch İsimlendirme

- Feature branch: `feature/phase01-step01`, `feature/phase01-step02`, ...
- Her Roadmap maddesi bir step'e karşılık gelir.
- Step numaraları phase içinde sıralıdır: step01, step02, ...

---

## Geliştirme Döngüsü (Her Step İçin)

1. `feature/phaseXX-stepYY` branch'i açılır.
2. Kod yazılır, build alınır.
3. Build başarılı olduğunda test raporu hazırlanır:
   - Bu step'te neler yapıldı?
   - Hangi ekranda hangi özellik görülmeli?
   - Nasıl test edilir? (madde madde)
4. Kullanıcı test eder ve onaylar.
5. Onay sonrası commit atılır, branch develop'a merge edilir, step kapatılır.
6. Tüm phase tamamlanınca develop → main merge edilir.

---

## Yetki & Onay

- Tüm komutlar için tam yetki verilmiştir.
- Git komutları, Xcode değişiklikleri, terminal komutları, local directory işlemleri için **onay istenmez**, direkt yapılır.

---

## Hafıza Kuralları

- Her yeni konuşmada ve her yeni kodlama başlangıcında hafıza okunur, kurallar hatırlanır.
- Yeni kurallar çıktığında anında hafızaya kaydedilir.
- Standartlara her zaman uyulur, branch yapısı asla bozulmaz.
