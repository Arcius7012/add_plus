﻿Перем РазницаВМилисекундахМеждуЮниксИНачалЭпохи;

// { Plugin interface
Функция ОписаниеПлагина(КонтекстЯдра, ВозможныеТипыПлагинов) Экспорт
	Результат = Новый Структура;
	Результат.Вставить("Тип", ВозможныеТипыПлагинов.ГенераторОтчета);
	Результат.Вставить("Идентификатор", Метаданные().Имя);
	Результат.Вставить("Представление", "Отчет о тестировании в формате XML для Yandex Allure версии 2");
	Результат.Вставить("ПотоковыйВывод", Истина);

	Возврат Новый ФиксированнаяСтруктура(Результат);
КонецФункции

Процедура Инициализация(КонтекстЯдраПараметр) Экспорт
КонецПроцедуры
// } Plugin interface

// { Report generator interface
Функция СоздатьОтчет(Знач КонтекстЯдра, Знач РезультатыТестирования) Экспорт
	ПостроительДереваТестов = КонтекстЯдра.Плагин("ПостроительДереваТестов");
	ЭтотОбъект.ТипыУзловДереваТестов = ПостроительДереваТестов.ТипыУзловДереваТестов;
	ЭтотОбъект.ИконкиУзловДереваТестов = ПостроительДереваТестов.ИконкиУзловДереваТестов;
	ЭтотОбъект.СостоянияТестов = КонтекстЯдра.СостоянияТестов;
	Отчет = СоздатьОтчетНаСервере(РезультатыТестирования);

	Возврат Отчет;
КонецФункции

Функция СоздатьОтчетНаСервере(Знач РезультатыТестирования) Экспорт

	МассивОписанийШагов = СоздатьОтчетАллюр2(РезультатыТестирования);

	РезНабор = Новый Массив;

	Для каждого ОписаниеШага Из МассивОписанийШагов Цикл
		СтрокаJSON = СериализоватьОписаниеШага(ОписаниеШага);

		Отчет = Новый ТекстовыйДокумент;
		Отчет.УстановитьТекст(СтрокаJSON);

		РезНабор.Добавить(Отчет);

	КонецЦикла;

	Возврат РезНабор;

КонецФункции

// Функция ЗаписатьРезультатТестаНаСервере(Знач РезультатТеста, Знач ПолныйПутьФайла) Экспорт
Функция ПолучитьРезультатТестаНаСервере(Знач РезультатТеста) Экспорт

	ОписаниеШага = СоздатьОписаниеШага(РезультатТеста);
	Отчет = СериализоватьОписаниеШага(ОписаниеШага);
	Возврат Отчет;
	// Экспортировать(Отчет, ПолныйПутьФайла);

КонецФункции

#Если ТолстыйКлиентОбычноеПриложение Тогда
Процедура Показать(Отчет) Экспорт
	Отчет.Показать();
КонецПроцедуры
#КонецЕсли

Процедура Экспортировать(Отчет, ПутьКОтчету) Экспорт

	Перем СтрокаJSON;

	Если ТипЗнч(Отчет) = Тип("Строка") Тогда
		СтрокаJSON = Отчет;
	Иначе
		СтрокаJSON = Отчет.ПолучитьТекст();
	КонецЕсли;

	ИмяФайла = ПутьКОтчету;

	ИмяФайла = ПолучитьУникальноеИмяФайла(ИмяФайла);

	Сообщение = "Уникальное имя файла " + ИмяФайла;
	ЗаписьЖурналаРегистрации("xUnitFor1C.ГенераторОтчетаAllureXMLВерсия2", УровеньЖурналаРегистрации.Информация, , , Сообщение);

	ПроверитьИмяФайлаРезультатаAllure(ИмяФайла);

	// Исключаем возможность записи в UTF-8 BOM
	ЗаписьТекста = Новый ЗаписьТекста(ИмяФайла, КодировкаТекста.ANSI);
	ЗаписьТекста.Закрыть();

	ЗаписьТекста = Новый ЗаписьТекста(ИмяФайла,,, Истина);
	ЗаписьТекста.Записать(СтрокаJSON);
	ЗаписьТекста.Закрыть();

КонецПроцедуры
// } Report generator interface

// { Helpers

Функция СоздатьОтчетАллюр2(РезультатыТестирования)

	МассивШагов = Новый Массив;
	КоллекцияРодителей = Новый Соответствие;
	ДобавитьШагТестированияВМассивШагов(РезультатыТестирования, МассивШагов, КоллекцияРодителей);

	МассивОписаний = Новый Массив;
	Для каждого РезультатШага Из МассивШагов Цикл
		ОписаниеШага = СоздатьОписаниеШага(РезультатШага, КоллекцияРодителей);
		МассивОписаний.Добавить(ОписаниеШага);
	КонецЦикла;

	Возврат МассивОписаний;
КонецФункции

Функция ОписаниеСценарияАллюр2()
	Перем СтруктураРезультата;

	GUID             = Новый УникальныйИдентификатор();
	СтруктураРезультата = Новый Структура(); //"uuid, historyId, name, status, parameters, labels, links, attachments");
	СтруктураРезультата.Вставить("uuid", Строка(GUID));
	СтруктураРезультата.Вставить("historyId", Неопределено);
	СтруктураРезультата.Вставить("name", Неопределено);
	СтруктураРезультата.Вставить("fullName", "");
	СтруктураРезультата.Вставить("start", Неопределено);
	СтруктураРезультата.Вставить("stop", Неопределено);
	СтруктураРезультата.Вставить("statusDetails",  Новый Структура("known, muted,flaky", Ложь, Ложь, Ложь));
	СтруктураРезультата.Вставить("status", Неопределено);
	СтруктураРезультата.Вставить("stage", "finished"); // Внятного описания, зачем это в каждом сценарии нет.
	СтруктураРезультата.Вставить("steps", Новый Массив());
	СтруктураРезультата.Вставить("parameters", Новый Массив());
	СтруктураРезультата.Вставить("labels", Новый Массив());
	СтруктураРезультата.Вставить("links", Новый Массив());
	СтруктураРезультата.Вставить("attachments", Новый Массив());
	СтруктураРезультата.Вставить("description", "");

	Возврат СтруктураРезультата;

КонецФункции

Процедура ДобавитьШагТестированияВМассивШагов(Знач РезультатыТестирования, Знач МассивШагов, Знач КоллекцияРодителей, Знач Родитель = Неопределено)

	Если ТипЗнч(РезультатыТестирования) = Тип("Массив") Тогда
		Для каждого Строка Из РезультатыТестирования Цикл
			КоллекцияРодителей.Вставить(Строка.Ключ, Родитель);
			ДобавитьШагТестированияВМассивШагов(Строка, МассивШагов, КоллекцияРодителей, Родитель);
		КонецЦикла;
	Иначе
		Строка = РезультатыТестирования;
		Если Строка.Тип = "Элемент" Тогда
			Строка.Вставить("Родитель", Родитель);
			МассивШагов.Добавить(Строка);
			КоллекцияРодителей.Вставить(Строка.Ключ, Родитель);
		Иначе
			ДобавитьШагТестированияВМассивШагов(Строка.Строки, МассивШагов, КоллекцияРодителей, Строка);
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

Функция НайтиПоКлючу(Знач КоллекцияРодителей, Знач Ключ)
	Рез = КоллекцияРодителей.Получить(Ключ);
	Возврат Рез;
КонецФункции

Функция СоздатьОписаниеШага(Знач РезультатШага, Знач КоллекцияРодителей = Неопределено)
	ОписаниеШага = ОписаниеСценарияАллюр2();

	Родитель = РезультатШага.Родитель;
	Если КоллекцияРодителей = Неопределено Тогда
		РодительРодителя = РезультатШага.Родитель.Родитель;
	Иначе
		РодительРодителя = НайтиПоКлючу(КоллекцияРодителей, Родитель.Ключ);
	КонецЕсли;

	ОписаниеШага.Вставить("name", РезультатШага.Представление);
	ОписаниеШага.Вставить("description", РезультатШага.ИмяМетода);

	ОписаниеШага.Вставить("start", РезультатШага.ВремяНачала - РазницаВМилисекундахМеждуЮниксИНачалЭпохи);
	ОписаниеШага.Вставить("stop", РезультатШага.ВремяОкончания - РазницаВМилисекундахМеждуЮниксИНачалЭпохи);

	ВставитьОписаниеСтатуса(ОписаниеШага, РезультатШага.Сообщение, РезультатШага.ПодробноеСообщение);

	ОписаниеШага.Вставить("status", СтатусАллюр(РезультатШага.Состояние));

	ИмяФичи = РодительРодителя.Имя;	
	ИмяСтори = Родитель.Имя;
	ИмяПакета = РезультатШага.Путь;
	ИмяХоста = ИмяФичи;
	
	// add_plus Настройка аллюра
	ИмяЭпика 	= "Дымовые тесты";	
	ИмяФичи = СтрЗаменить(ИмяФичи, "УпрФорма # ", "");	

	ПервыйПробел = СтрНайти(ИмяФичи, "_");
	
	Если ПервыйПробел <> 0 Тогда
		ИмяФичи = Лев(ИмяФичи, ПервыйПробел - 1) + "." + Прав(ИмяФичи, СтрДлина(ИмяФичи) - ПервыйПробел);
	КонецЕсли;
	
	ИмяФичи = СтрЗаменить(ИмяФичи, "_", " ");
		
	ИмяСьюита = ИмяЭпика;
	ИмяПакета = ИмяЭпика;
	// add_plus

	ОписаниеШага.historyId = СтрШаблон_("%1.%2.%3", ИмяФичи, ИмяСтори, РезультатШага.Представление);

	СписокМеток = ОписаниеШага.labels;
	ДобавитьМетку(СписокМеток, "host", ИмяХоста);
	ДобавитьМетку(СписокМеток, "package", ИмяПакета);
	ДобавитьМетку(СписокМеток, "feature", ИмяФичи);
	ДобавитьМетку(СписокМеток, "story", ИмяСтори);
	
	// add_plus Настройка аллюра
	ДобавитьМетку(СписокМеток, "epic", 	ИмяЭпика);
	ДобавитьМетку(СписокМеток, "suite", ИмяСьюита);
	// add_plus
	
	// при заполнении параметров в ОписаниеШага.parameters тесты перестают быть видны в отчете Аллюр :(
	//Параметры = ОписаниеШага.parameters;
	//Для каждого Параметр Из РезультатШага.Параметры Цикл
	//	Параметры.Добавить("" + Параметр);
	//КонецЦикла;

	Возврат ОписаниеШага;
КонецФункции

Процедура ВставитьОписаниеСтатуса(Знач ОписаниеШага, Знач ОписаниеОшибки = "", Знач Трейс = "")

	ОписаниеШага.Вставить("statusDetails",
		Новый Структура("known, muted, flaky, message, trace",
			Ложь, Ложь, Ложь, ОписаниеОшибки, Трейс));
КонецПроцедуры

Функция СтатусАллюр(Знач СостояниеШага)
	Рез = "skipped";
	Если СостояниеШага = СостоянияТестов.Пройден Тогда
		Рез = "passed";
	ИначеЕсли СостояниеШага = СостоянияТестов.Сломан Тогда
		Рез = "broken";
	ИначеЕсли СостояниеШага = СостоянияТестов.НеизвестнаяОшибка Тогда
		Рез = "failed";
	ИначеЕсли СостояниеШага = СостоянияТестов.НеРеализован Тогда
		Рез = "skipped";
	КонецЕсли;

	Возврат Рез;
КонецФункции

Процедура ДобавитьМетку(Знач СписокМеток, Знач Имя, Знач Значение)

	Метка       = Новый Структура("name, value");
	Метка.name  = Имя;
	Метка.value = Значение;

	СписокМеток.Вставить(0, Метка);

КонецПроцедуры

// Замена функции СтрШаблон на конфигурациях с режимом совместимости < 8.3.6
// При внедрении в конфигурацию с режимом совместимости >= 8.3.6 данную функцию необходимо удалить
//
Функция СтрШаблон_(Знач СтрокаШаблон, Знач Парам1 = Неопределено, Знач Парам2 = Неопределено, Знач Парам3 = Неопределено, Знач Парам4 = Неопределено) Экспорт

	МассивПараметров = Новый Массив;
	МассивПараметров.Добавить(Парам1);
	МассивПараметров.Добавить(Парам2);
	МассивПараметров.Добавить(Парам3);
	МассивПараметров.Добавить(Парам4);

	Для Сч = 1 По МассивПараметров.Количество() Цикл
		ТекЗначение = МассивПараметров[Сч-1];
		СтрокаШаблон = СтрЗаменить(СтрокаШаблон, "%"+Сч, Строка(ТекЗначение));
	КонецЦикла;
	Возврат СтрокаШаблон;
КонецФункции

// задаю уникальное имя для возможности получения одного отчета allure по разным тестовым наборам
Функция ПолучитьУникальноеИмяФайла(Знач ПутьКОтчету)

	Файл = Новый Файл(ПутьКОтчету);
	ГУИД = Новый УникальныйИдентификатор;

	ПутьКаталога = ?(Файл.Существует() И Файл.ЭтоКаталог(), Файл.ПолноеИмя, Файл.Путь);
	ИмяФайла = СтрШаблон_("%1-result.json", ГУИД);

	ИмяФайла = СтрШаблон_("%1/%2", ПутьКаталога, ИмяФайла);

	Возврат ИмяФайла;
КонецФункции

Процедура ПроверитьИмяФайлаРезультатаAllure(ИмяФайла) Экспорт
	Сообщение = "";
	Файл = Новый Файл(ИмяФайла);
	Если Найти(Файл.Имя, "-result") = 0 Тогда
		Сообщение = СтрШаблон_("%1
			|Файл-результат для Allure 2 должен заканчиваться на ""-result.json""
			|Иначе Allure не покажет результаты тестирования
			|А сейчас имя файла %2",
			Сообщение, Файл.ПолноеИмя);
	КонецЕсли;
	Если  Файл.Расширение <> ".json" Тогда
		Сообщение = СтрШаблон_("%1
			|Файл-результат для Allure 2 должен иметь расширение ""json""
			|Иначе Allure не покажет результаты тестирования",
			Сообщение);
	КонецЕсли;
	Если Не ПустаяСтрока (Сообщение) Тогда
		ВызватьИсключение Сообщение;
	КонецЕсли;
КонецПроцедуры

Функция СериализоватьОписаниеШага(ОписаниеШага)

	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON, ОписаниеШага);
	СтрокаJSON = ЗаписьJSON.Закрыть();

	Возврат СтрокаJSON;

КонецФункции

// } Helpers

РазницаВМилисекундахМеждуЮниксИНачалЭпохи = 62135596800000;
