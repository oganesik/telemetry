// pid_definitions.dart

/// Класс, описывающий информацию об одном PID:
class PidInfo {
  /// Человеко-читабельное описание PID-а на русском языке.
  final String description;

  const PidInfo(this.description);
}

/// Словарь, сопоставляющий PID (двухсимвольный hex) → описание на русском.
/// Перечислены самые популярные Mode 01 PID-ы (0x01–0x20). Можно дополнять при необходимости.
const Map<String, PidInfo> pidDefinitions = {
  // Mode 01 PID 0x01:
  '01': PidInfo('Статус бортовой диагностики с момента очищения кодов DTC'),

  // Mode 01 PID 0x02:
  '02': PidInfo('Замороженный код неисправности (Freeze DTC)'),

  // Mode 01 PID 0x03:
  '03': PidInfo('Состояние топливной системы (Fuel system status)'),

  // Mode 01 PID 0x04:
  '04': PidInfo('Рассчитанная нагрузка двигателя (Calculated engine load)'),

  // Mode 01 PID 0x05:
  '05': PidInfo('Температура охлаждающей жидкости двигателя'),

  // Mode 01 PID 0x06:
  '06': PidInfo('Краткосрочная коррекция подачи топлива, банк 1'),

  // Mode 01 PID 0x07:
  '07': PidInfo('Долгосрочная коррекция подачи топлива, банк 1'),

  // Mode 01 PID 0x08:
  '08': PidInfo('Краткосрочная коррекция подачи топлива, банк 2'),

  // Mode 01 PID 0x09:
  '09': PidInfo('Долгосрочная коррекция подачи топлива, банк 2'),

  // Mode 01 PID 0x0A:
  '0A': PidInfo('Давление топлива'),

  // Mode 01 PID 0x0B:
  '0B': PidInfo('Абсолютное давление во впускном коллекторе (MAP)'),

  // Mode 01 PID 0x0C:
  '0C': PidInfo('Обороты двигателя (Engine RPM)'),

  // Mode 01 PID 0x0D:
  '0D': PidInfo('Скорость автомобиля (Vehicle Speed)'),

  // Mode 01 PID 0x0E:
  '0E': PidInfo('Угол опережения зажигания (Timing Advance)'),

  // Mode 01 PID 0x0F:
  '0F': PidInfo('Температура всасываемого воздуха (Intake Air Temp)'),

  // Mode 01 PID 0x10:
  '10': PidInfo('Расход воздуха (Mass Air Flow Rate)'),

  // Mode 01 PID 0x11:
  '11': PidInfo('Положение дроссельной заслонки (Throttle Position)'),

  // Mode 01 PID 0x12:
  '12': PidInfo('Состояние вторичной подачи воздуха (Secondary Air Status)'),

  // Mode 01 PID 0x13:
  '13': PidInfo('Напряжение лямбда-зонда 1, банк 1 (O₂ Sensor 1 Voltage)'),

  // Mode 01 PID 0x14:
  '14': PidInfo('Напряжение лямбда-зонда 2, банк 1 (O₂ Sensor 2 Voltage)'),

  // Mode 01 PID 0x15:
  '15': PidInfo('Напряжение лямбда-зонда 3, банк 1 (O₂ Sensor 3 Voltage)'),

  // Mode 01 PID 0x16:
  '16': PidInfo('Напряжение лямбда-зонда 4, банк 1 (O₂ Sensor 4 Voltage)'),

  // Mode 01 PID 0x17:
  '17': PidInfo('Ток лямбда-зонда 1, банк 1 (O₂ Sensor 1 Current)'),

  // Mode 01 PID 0x18:
  '18': PidInfo('Ток лямбда-зонда 2, банк 1 (O₂ Sensor 2 Current)'),

  // Mode 01 PID 0x19:
  '19': PidInfo('Ток лямбда-зонда 3, банк 1 (O₂ Sensor 3 Current)'),

  // Mode 01 PID 0x1A:
  '1A': PidInfo('Ток лямбда-зонда 4, банк 1 (O₂ Sensor 4 Current)'),

  // Mode 01 PID 0x1B:
  '1B': PidInfo('Напряжение лямбда-зонда 1, банк 2 (O₂ Sensor 1 Voltage)'),

  // Mode 01 PID 0x1C:
  '1C': PidInfo('Напряжение лямбда-зонда 2, банк 2 (O₂ Sensor 2 Voltage)'),

  // Mode 01 PID 0x1D:
  '1D': PidInfo('Напряжение лямбда-зонда 3, банк 2 (O₂ Sensor 3 Voltage)'),

  // Mode 01 PID 0x1E:
  '1E': PidInfo('Напряжение лямбда-зонда 4, банк 2 (O₂ Sensor 4 Voltage)'),

  // Mode 01 PID 0x1F:
  '1F': PidInfo('Ток лямбда-зонда 1, банк 2 (O₂ Sensor 1 Current)'),

  // Mode 01 PID 0x20:
  '20': PidInfo('Поддержка PID 21–40 (Bitmask)'),
};
