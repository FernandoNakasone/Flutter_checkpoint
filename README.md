# 🚗 SpotReserve - Sistema de Reserva de Vagas (Flutter)

### Prova Prática: Testes de Unidade e Mocks com Mocktail

Avaliação prática desenvolvida para a disciplina de **Desenvolvimento Mobile com Flutter** na **FIAP**.

O objetivo da avaliação é exercitar a criação de testes de unidade automatizados para regras de negócio com **Flutter Test** e **Mocktail**, aplicando os mesmos conceitos vistos em sala de aula (no exemplo do Carrinho de Compras e serviço fake de CEP) em um sistema de **Reserva de Vagas**.

---

## 📂 Estrutura do Projeto

```text
reserva_vagas/
├── PROVA.md                                       # Enunciado oficial da avaliação (50 min / 10 pontos)
├── lib/
│   ├── models/
│   │   ├── exceptions.dart                        # Exceções (InvalidPlateException, etc.)
│   │   └── reservation.dart                       # Entidade de Reserva
│   ├── services/
│   │   ├── holiday_service.dart                   # Interface HolidayService + FakeHolidayService
│   │   └── reservation_manager.dart               # CLASSE PRINCIPAL DE NEGÓCIO A SER TESTADA
│   ├── ui/
│   │   └── screens/
│   │       └── reservation_screen.dart            # Interface visual do app
│   └── main.dart                                  # Entrada do app Flutter
├── test/
│   ├── reservation_manager_student_test.dart      # ARQUIVO DE ENTREGA DO ALUNO (com TODOs)
│   ├── reservation_manager_test.dart              # Suíte de testes padrão
│   └── gabarito/
│       └── reservation_manager_gabarito_test.dart # GABARITO OFICIAL DO PROFESSOR (100% dos testes)
└── pubspec.yaml                                   # mocktail, intl, flutter_test
```

---

## 🚀 Como Executar o Aplicativo

Para visualizar e testar a interface gráfica do aplicativo no simulador, Windows ou navegador:

```bash
flutter pub get
flutter run
```

---

## 🧪 Como Executar os Testes de Unidade

### 2. Testes da Prova do Aluno

```bash
flutter test test/reservation_manager_student_test.dart
```

---

## 📄 Enunciado da Prova

Consulte o arquivo [`PROVA.md`](PROVA.md) para ler o enunciado completo com tabela de pontuação (10,0 pontos / 50 minutos), regras de negócio e orientações de entrega.
