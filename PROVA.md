# 📋 FIAP - Avaliação Prática de Desenvolvimento Mobile com Flutter
## Tema: Testes de Unidade e Mocks de Serviços com Mocktail em Classes de Negócio
**Valor Total:** 10,0 Pontos  
**Duração da Avaliação:** 50 Minutos  
**Disciplina:** Mobile Development / Flutter  
**Projeto Base:** `SpotReserve` - Sistema de Reserva de Vagas  

---

## 📌 1. Apresentação do Cenário e Contexto

Você foi contratado como desenvolvedor Flutter para garantir a confiabilidade do motor de reservas do aplicativo **SpotReserve**.

Durante as aulas, você aprendeu a:
1. Criar **testes de unidade** para validar regras de negócio puras (como no exemplo do Carrinho de Compras, calculando totais, descontos progressivos e validando limites).
2. Utilizar o pacote **`mocktail`** para mockar serviços e dependências externas (como foi feito no cálculo de frete a partir do serviço fake de CEP).

Nesta avaliação, você aplicará esses conceitos no sistema de **reserva de vagas**, no qual o cliente informa a **placa do veículo**, a **data/hora de início** e a **quantidade de horas**. A classe de negócio `ReservationManager` consome o serviço externo `HolidayService` para saber se a data reservada é um feriado nacional e tarifar adequadamente. *(Nota: Por simplificação, o sistema apenas efetua a reserva e calcula os valores, sem controle de capacidade/cancelamento)*.

Sua tarefa é **implementar a suíte de testes de unidade automatizados** no arquivo:  
📂 `test/reservation_manager_student_test.dart`

---

## 🏗️ 2. Arquitetura do Módulo

```text
lib/
├── models/
│   ├── exceptions.dart           # Exceções (InvalidPlateException, InvalidDurationException, etc.)
│   └── reservation.dart          # Modelo da reserva (placa, horários, tarifas)
├── services/
│   ├── holiday_service.dart      # Contrato abstrato HolidayService + FakeHolidayService
│   └── reservation_manager.dart  # CLASSE CENTRAL DE NEGÓCIO A SER TESTADA
├── ui/
│   └── screens/
│       └── reservation_screen.dart # Tela Flutter para testes visuais
└── main.dart                     # Inicialização do app
```

### Contrato do Serviço Externo a ser Mockado:
```dart
abstract class HolidayService {
  Future<bool> isHoliday(DateTime date);
}
```

---

## 📐 3. Regras de Negócio do Sistema

| Regra | Descrição | Comportamento Esperado |
|---|---|---|
| **R1 - Placa do Veículo** | A placa deve ter exatamente **7 caracteres alfanuméricos** (ex: `BRA2E19`, `ABC1234`). Espaços e traços devem ser ignorados. | Se a placa for nula ou não tiver 7 caracteres, dispara `InvalidPlateException`. |
| **R2 - Quantidade de Horas** | A reserva deve ser de no **mínimo 1 hora** e no **máximo 24 horas**. | Valores fora desse intervalo disparam `InvalidDurationException`. |
| **R3 - Data de Início** | A reserva não pode ter início no passado em relação ao horário atual. | Se for anterior ao horário atual, dispara `InvalidReservationDateException`. |
| **R4 - Tarifa Base** | Cada hora custa a tarifa base de **R$ 10,00/hora**. | `baseAmount = horas * 10.0`. |
| **R5 - Desconto por Permanência** | Incentivo para reservas mais longas. | • **Menos de 4 horas:** 0% de desconto.<br>• **De 4 a 7 horas:** 10% de desconto sobre a tarifa base.<br>• **A partir de 8 horas:** 20% de desconto sobre a tarifa base. |
| **R6 - Taxa de Feriado (`HolidayService`)** | O sistema consulta se a data é feriado via `holidayService.isHoliday(date)`. | • Se retornar `true`: acréscimo de **+25%** sobre o valor base.<br>• Se retornar `false`: acréscimo **R$ 0,00**. |
| **R7 - Resiliência a Falhas Externas** | Caso a API externa de feriados caia ou lance exceção (ex: timeout de rede). | O sistema captura a falha e assume com segurança `isHoliday = false` (taxa R$ 0,00), sem interromper o cálculo da reserva. |

---

## 📝 4. Questões da Prova (Total: 10,0 Pontos)

Os testes devem ser implementados dentro do arquivo:  
📂 `test/reservation_manager_student_test.dart`

### 🔹 Questão 1: Validações de Entrada e Limites (3,0 Pontos)
- **1.1 (1,0 pt)**: Validar que placas nulas, com menos de 7 ou mais de 7 caracteres disparam `InvalidPlateException`, e que placas formatadas (ex: `'abc-1234'`, `'bra2e19'`) passam normalmente pela sanitização.
- **1.2 (1,0 pt)**: Validar que valores de horas inválidos (< 1 ou > 24) disparam `InvalidDurationException`, e que os limites válidos (1h e 24h) passam normalmente.
- **1.3 (1,0 pt)**: Validar que datas anteriores ao momento atual disparam `InvalidReservationDateException`, e datas futuras passam normalmente.

### 🔹 Questão 2: Regras de Cálculo e Descontos por Duração - Sem Mock (3,0 Pontos)
- **2.1 (1,0 pt)**: Validar que reservas com menos de 4 horas (ex: 3h) não recebem desconto (3h × R$ 10 = R$ 30,00; desconto R$ 0,00; total = R$ 30,00).
- **2.2 (1,0 pt)**: Validar que reservas entre 4 e 7 horas (ex: 5h) recebem 10% de desconto sobre o valor base (5h × R$ 10 = R$ 50,00; desconto R$ 5,00; total = R$ 45,00).
- **2.3 (1,0 pt)**: Validar que reservas com 8 horas ou mais (ex: 10h) recebem 20% de desconto sobre o valor base (10h × R$ 10 = R$ 100,00; desconto R$ 20,00; total = R$ 80,00).

### 🔹 Questão 3: Integração com Mocktail no HolidayService (3,0 Pontos)
- **3.1 (1,5 pt)**: Configurar o mock `when(() => mockHolidayService.isHoliday(any())).thenAnswer((_) async => true)`. Calcular o preço de 2 horas (base R$ 20,00) e verificar que `holidaySurcharge` é R$ 5,00 (+25%) e o total é R$ 25,00. Utilizar `verify(() => mockHolidayService.isHoliday(any())).called(1)` para comprovar a consulta.
- **3.2 (1,5 pt)**: Configurar o mock para retornar `false`. Calcular para 2 horas e validar que `holidaySurcharge` é R$ 0,00 e o total é R$ 20,00, verificando a chamada com `verify`.

### 🔹 Questão 4: Resiliência a Exceções com Mocktail (1,0 Ponto)
- **4.1 (1,0 pt)**: Simular erro externo usando `when(() => mockHolidayService.isHoliday(any())).thenThrow(Exception('Timeout na API'))`. Validar que o cálculo conclui sem estourar exceção, considerando `isHoliday = false`, taxa R$ 0,00 e valor total R$ 20,00 para 2 horas de reserva.

---

## 💡 Dicas de Testes no Flutter & Matchers Úteis

### Como testar métodos `void` de validação:

1. **Testando o "Caminho Feliz" (quando o valor é válido e NÃO deve lançar erro):**
   Utilize o matcher `returnsNormally` para garantir que o método executou sem disparar nenhuma exceção:
   ```dart
   // Exemplo: Placa válida não deve lançar exceção
   expect(() => manager.validatePlate('BRA2E19'), returnsNormally);
   expect(() => manager.validatePlate('abc-1234'), returnsNormally);

   // Exemplo: Horas válidas (1h e 24h)
   expect(() => manager.validateDuration(1), returnsNormally);
   expect(() => manager.validateDuration(24), returnsNormally);

   // Exemplo: Data no futuro
   expect(() => manager.validateStartTime(dataFutura), returnsNormally);
   ```

2. **Testando o disparo de Exceções esperadas:**
   Utilize `throwsA(isA<TipoDaExcecao>())`:
   ```dart
   // Exemplo: Placa inválida deve lançar InvalidPlateException
   expect(() => manager.validatePlate('ABC'), throwsA(isA<InvalidPlateException>()));
   expect(() => manager.validatePlate(null), throwsA(isA<InvalidPlateException>()));
   ```

---

## 💡 Dicas de Sintaxe do Mocktail

O pacote **Mocktail** dispensa o uso de `build_runner`. Basta declarar a classe mock diretamente no seu arquivo de testes:

```dart
// 1. Criação da classe Mock
class MockHolidayService extends Mock implements HolidayService {}

// 2. Mockando resposta de sucesso (Future):
when(() => mockHolidayService.isHoliday(any())).thenAnswer((_) async => true);

// 3. Mockando simulação de erro/exceção:
when(() => mockHolidayService.isHoliday(any())).thenThrow(Exception('Falha de rede'));

// 4. Verificando se o método foi executado:
verify(() => mockHolidayService.isHoliday(any())).called(1);
```

---

## 🛠️ Comandos Úteis no Terminal

- **Obter dependências:**
  ```bash
  flutter pub get
  ```

- **Rodar os seus testes:**
  ```bash
  flutter test test/reservation_manager_student_test.dart
  ```

---

## 📦 Instruções de Entrega

1. Abra o arquivo `test/reservation_manager_student_test.dart` e preencha seu **Nome Completo** e **RM** no cabeçalho.
2. Certifique-se de que todos os testes implementados rodem sem erros de compilação.
3. Submeta o arquivo `test/reservation_manager_student_test.dart` no portal da disciplina.

Boa prova! 🚀
