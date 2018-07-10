#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

Функция ПолучитьПрогноз(ТаблицаИстории, ГоризонтПланирования, СтруктураПараметров = Неопределено) Экспорт
	
	Если СтруктураПараметров = Неопределено Тогда
		СтруктураПараметров = Новый Структура;
	КонецЕсли;
	
	Если ТаблицаИстории.Количество() < 2 Тогда
		ВызватьИсключение("Ошибка получения прогноза. Таблица истории должна иметь по крайней мере две точки.");
	КонецЕсли;
	Если ГоризонтПланирования < 0 Тогда
		ВызватьИсключение("Ошибка получения прогноза. Горизонт планирования не может быть отрицателным.");
	КонецЕсли;
	
	Соединение = Новый HTTPСоединение(ИмяСервера());
	
	ДанныеЗапроса = Новый Структура;
	ДанныеЗапроса.Вставить("history", История(ТаблицаИстории, СтруктураПараметров));
	ДанныеЗапроса.Вставить("periods", ГоризонтПланирования);
	ДанныеЗапроса.Вставить("freq", Частота(СтруктураПараметров));
	HTTPЗапрос = СоздатьЗапрос("forecast", ДанныеЗапроса);
	Ответ = Соединение.ОтправитьДляОбработки(HTTPЗапрос);
	ПроверитьОтвет(Ответ, "Ошибка получения прогноза");
	
	ДанныеОтвета = _ОбщегоНазначения.ЗначениеИзJSONСтроки(Ответ.ПолучитьТелоКакСтроку());
	Возврат ТаблицаПрогноза(ДанныеОтвета);
	
КонецФункции

Функция История(ТаблицаИстории, Знач СтруктураПараметров = Неопределено)
	
	Если СтруктураПараметров.Свойство("ИмяКолонкиДаты") Тогда
		ИмяКолонкиДаты = СтруктураПараметров.ИмяКолонкиДаты;
	Иначе
		ИмяКолонкиДаты = "Дата";
	КонецЕсли;
	Если СтруктураПараметров.Свойство("ИмяКолонкиФакта") Тогда
		ИмяКолонкиФакта = СтруктураПараметров.ИмяКолонкиФакта;
	Иначе
		ИмяКолонкиФакта = "Факт";
	КонецЕсли;
	Таблица = ТаблицаИстории.Скопировать(, ИмяКолонкиДаты + "," + ИмяКолонкиФакта);
	Таблица.Колонки[ИмяКолонкиДаты].Имя = "ds";
	Таблица.Колонки[ИмяКолонкиФакта].Имя = "y";
	Возврат _ОбщегоНазначения.ТаблицаВМассивСтруктур(Таблица);
	
КонецФункции

Функция Частота(СтруктураПараметров)
	
	Если Не СтруктураПараметров.Свойство("Частота") Тогда
		Возврат "D";
	КонецЕсли;
	
	Если СтруктураПараметров.Частота = "День" Тогда
		Частота = "D";
	ИначеЕсли СтруктураПараметров.Частота = "Неделя" Тогда
		Частота = "W";
	ИначеЕсли СтруктураПараметров.Частота = "Месяц" Тогда
		Частота = "MS";
	ИначеЕсли СтруктураПараметров.Частота = "Квартал" Тогда
		Частота = "QS";
	ИначеЕсли СтруктураПараметров.Частота = "Год" Тогда
		Частота = "YS";
	ИначеЕсли СтруктураПараметров.Частота = "Час" Тогда
		Частота = "H";
	ИначеЕсли СтруктураПараметров.Частота = "Минута" Тогда
		Частота = "T";
	ИначеЕсли СтруктураПараметров.Частота = "Секунда" Тогда
		Частота = "S";
	Иначе
		ТекстИсключения = НСтр("ru = 'Для частоты %1 не определен формат для Пророка'");
		ТекстИсключения = СтрШаблон(ТекстИсключения, СтруктураПараметров.Частота);
		ВызватьИсключение(ТекстИсключения);
	КонецЕсли;
	
	Возврат Частота;
	
КонецФункции

Функция ТаблицаПрогноза(ДанныеОтвета)
	
	ТаблицаПрогноза = Новый ТаблицаЗначений;
	Для Каждого ИмяКолонки Из ДанныеОтвета.columns Цикл
		Если ИмяКолонки = "ds" Тогда
			ТаблицаПрогноза.Колонки.Добавить(ИмяКолонки, Новый ОписаниеТипов("Дата"));
		Иначе
			ТаблицаПрогноза.Колонки.Добавить(ИмяКолонки, Новый ОписаниеТипов("Число"));
		КонецЕсли;
	КонецЦикла;
	Для Каждого ДанныеСтроки из ДанныеОтвета.data Цикл
		НоваяСтрока = ТаблицаПрогноза.Добавить();
		Индекс = 0;
		Для Каждого ИмяКолонки Из ДанныеОтвета.columns Цикл
			Если ИмяКолонки = "ds" Тогда
				НоваяСтрока[ИмяКолонки] = ПолучитьДатуИзUТС(ДанныеСтроки[Индекс]);
			Иначе
				НоваяСтрока[ИмяКолонки] = ДанныеСтроки[Индекс];
			КонецЕсли;
			Индекс = Индекс + 1;
		КонецЦикла;
	КонецЦикла;
	
	ТаблицаПрогноза.Колонки.ds.Имя = "Дата";
	ТаблицаПрогноза.Колонки.trend.Имя = "Тренд";
	ТаблицаПрогноза.Колонки.trend_lower.Имя = "Тренд_НижняяГраница";
	ТаблицаПрогноза.Колонки.trend_upper.Имя = "Тренд_ВерхняяГраница";
	ТаблицаПрогноза.Колонки.yhat.Имя = "Прогноз";
	ТаблицаПрогноза.Колонки.yhat_lower.Имя = "Прогноз_НижняяГраница";
	ТаблицаПрогноза.Колонки.yhat_upper.Имя = "Прогноз_ВерхняяГраница";
	
	Возврат ТаблицаПрогноза;
	
КонецФункции

#КонецОбласти

#Область Общее

Функция ИмяСервера()
	
	Возврат "192.168.99.100:4000";
	
КонецФункции

Функция СоздатьЗапрос(АдресРесурса, ДанныеЗапроса)
	
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Content-Type", "application/json");
	HTTPЗапрос = Новый HTTPЗапрос(АдресРесурса, Заголовки);
	
	Если Не ДанныеЗапроса = Неопределено Тогда
		HTTPЗапрос.УстановитьТелоИзСтроки(_ОбщегоНазначения.СтрокаJSONИзЗначения(ДанныеЗапроса));
	КонецЕсли;
	
	Возврат HTTPЗапрос;
	
КонецФункции

Процедура ПроверитьОтвет(Ответ, СообщениеПриОшибке, Знач ПоложительныйКодСостояния = Неопределено)
	
	Если ПоложительныйКодСостояния = Неопределено Тогда
		ПоложительныйКодСостояния = 200;
	КонецЕсли;
	
	Если Не Ответ.КодСостояния = ПоложительныйКодСостояния Тогда
		ВызватьИсключение(СообщениеПриОшибке + " " + Ответ.ПолучитьТелоКакСтроку());
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ПриведениеТипов

Функция ПолучитьДатуИзUТС(Число)
	
	Возврат '19700101' + Число / 1000;
	
КонецФункции

#КонецОбласти

#КонецЕсли
