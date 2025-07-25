﻿&НаКлиенте
Перем КэшПостроительДереваТестов;
&НаКлиенте
Перем ЗагружаемыйПуть;

&НаКлиенте
Перем КонтейнерТестов;
&НаКлиенте
Перем ТекущаяГруппа;

&НаКлиенте
Перем ЕстьПоддержкаАсинхронныхВызовов;

// { Plugin interface
&НаКлиенте
Функция ОписаниеПлагина(КонтекстЯдра, ВозможныеТипыПлагинов) Экспорт
	Возврат ОписаниеПлагинаНаСервере(ВозможныеТипыПлагинов);
КонецФункции

&НаКлиенте
Процедура Инициализация(КонтекстЯдраПараметр) Экспорт
	ЕстьПоддержкаАсинхронныхВызовов = КонтекстЯдраПараметр.ЕстьПоддержкаАсинхронныхВызовов;
КонецПроцедуры

&НаСервере
Функция ОписаниеПлагинаНаСервере(ВозможныеТипыПлагинов)
	КонтекстЯдраНаСервере = ВнешниеОбработки.Создать("xddTestRunner");
	Возврат ЭтотОбъектНаСервере().ОписаниеПлагина(КонтекстЯдраНаСервере, ВозможныеТипыПлагинов);
КонецФункции
// } Plugin interface

// { Loader interface
&НаКлиенте
Функция ВыбратьПутьИнтерактивно(КонтекстЯдра, ТекущийПуть = "") Экспорт
	
	ДиалогВыбораТеста = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДиалогВыбораТеста.Фильтр = "Обработка-тест (*.epf)|*.epf|Отчет-тест (*.erf)|*.erf|Все файлы|*";
	ДиалогВыбораТеста.МножественныйВыбор = Истина;
	ДиалогВыбораТеста.ПроверятьСуществованиеФайла = Истина;
	ДиалогВыбораТеста.ПолноеИмяФайла = ТекущийПуть;
	
	Результат = Новый ТекстовыйДокумент;
	ДиалогВыбораТеста.Показать(Новый ОписаниеОповещения("ВыбратьПутьИнтерактивноЗавершение", ЭтаФорма,
		Новый Структура("ДиалогВыбораТеста, Результат, КонтекстЯдра", ДиалогВыбораТеста, Результат, КонтекстЯдра)));
	Возврат "";
КонецФункции

#Область АсинхронныйAPI

&НаКлиенте
Процедура НачатьЗагрузку(Знач ОбработчикОповещения, Знач КонтекстЯдра, Знач Путь) Экспорт
	Объект.ИспользоватьПрямыеПутиФайлов = КонтекстЯдра.Объект.ИспользоватьПрямыеПутиФайлов;
	
	ПолноеИмяБраузераТестов = КонтекстЯдра.Объект.ПолноеИмяБраузераТестов;
	
	ПостроительДереваТестов = КонтекстЯдра.Плагин("ПостроительДереваТестов");
	ДеревоТестов = Неопределено;
	
	// TODO: Поддержать цикл по нескольким файлам в Пути
	
	Для Счетчик = 1 По СтрЧислоСтрок(Путь) Цикл
		ФайлОбработки = Новый Файл(СтрПолучитьСтроку(Путь, Счетчик));
		
		Если ДеревоТестов = Неопределено Тогда
			ДеревоТестов = ПостроительДереваТестов.СоздатьКонтейнер(ФайлОбработки.Путь);
		КонецЕсли;
		
		ПараметрыОповещения = Новый Структура;
		ПараметрыОповещения.Вставить("ФайлОбработки", ФайлОбработки);
		ПараметрыОповещения.Вставить("ПостроительДереваТестов", ПостроительДереваТестов);
		ПараметрыОповещения.Вставить("ДеревоТестов", ДеревоТестов);
		ПараметрыОповещения.Вставить("ОбработчикОповещения", ОбработчикОповещения);
		ПараметрыОповещения.Вставить("КонтекстЯдра", КонтекстЯдра);
		Если Объект.ИспользоватьПрямыеПутиФайлов Тогда
			ЗагрузкаВнешнейОбработкиЗавершение(, ПараметрыОповещения);
		Иначе
			Обработчик = Новый ОписаниеОповещения("ЗагрузкаВнешнейОбработкиЗавершение", ЭтаФорма, ПараметрыОповещения);
			КонтекстЯдра.НачатьПодключениеВнешнейОбработки(Обработчик, ФайлОбработки);
		КонецЕсли;
		
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузкаВнешнейОбработкиЗавершение(Знач Результат, Знач ДополнительныеПараметры) Экспорт
	
	ФайлОбработки = ДополнительныеПараметры.ФайлОбработки;
	ПостроительДереваТестов = ДополнительныеПараметры.ПостроительДереваТестов;
	ДеревоТестов = ДополнительныеПараметры.ДеревоТестов;
	КонтекстЯдра = ДополнительныеПараметры.КонтекстЯдра;
	
	ИмяОбработки = "";
	МассивСообщений = Неопределено;

	Попытка
		
		// add_plus
		ПлагинНастройки = КонтекстЯдра.Плагин("Настройки");
		ПлагинНастройки.Инициализация(КонтекстЯдра);
		
		Настройки = ПлагинНастройки.ПолучитьНастройку(ФайлОбработки.ИмяБезРасширения);
		
		КонтейнерССервернымиТестамиОбработки = ЗагрузитьФайлНаСервере(ФайлОбработки.ПолноеИмя, ИмяОбработки, 
			КонтекстЯдра.Объект, МассивСообщений, Настройки);
		// add_plus
		
		КонтейнерСКлиентскимиТестамиОбработки = ЗагрузитьФайлНаКлиенте(ПостроительДереваТестов, ФайлОбработки, 
			КонтекстЯдра, ИмяОбработки);
		Если КонтейнерСКлиентскимиТестамиОбработки.Строки.Количество() > 0 Тогда
			КонтейнерССервернымиТестамиОбработки.Строки.Добавить(КонтейнерСКлиентскимиТестамиОбработки);
		КонецЕсли;
		Если КонтейнерССервернымиТестамиОбработки.Строки.Количество() > 0 Тогда
			ДеревоТестов.Строки.Добавить(КонтейнерССервернымиТестамиОбработки);
		КонецЕсли;
	
	Исключение
	
		// стандарт по исключениям https://its.1c.ru/db/v8std/content/499/hdoc
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		ПолныйТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке);
		
		ПолныйТекстОшибки = СтрШаблон("Не удалось загрузить файл %2
		|%1", ПолныйТекстОшибки, ФайлОбработки.ПолноеИмя);
		
		КонтекстЯдра.ЗафиксироватьОшибкуВЖурналеРегистрации("ЗагрузкаТестов", ПолныйТекстОшибки);
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = ПолныйТекстОшибки;
		Сообщение.Сообщить();
		
		ПолныйТекстОшибкиБезСтека = КонтекстЯдра.ПолучитьСообщениеБезСтекаВызововОтБраузераТестов(ПолныйТекстОшибки);
		КонтекстЯдра.ВывестиСообщениеВЛогФайл(ПолныйТекстОшибкиБезСтека);
	
	КонецПопытки;
		
	КонтекстЯдра.ВывестиНакопленныеСообщенияОтСервераВРежимеОтладки(МассивСообщений);
	
	ВыполнитьОбработкуОповещения(ДополнительныеПараметры.ОбработчикОповещения, ДеревоТестов);
	
КонецПроцедуры

#КонецОбласти

&НаКлиенте
Функция Загрузить(КонтекстЯдра, Путь) Экспорт
	Объект.ИспользоватьПрямыеПутиФайлов = КонтекстЯдра.Объект.ИспользоватьПрямыеПутиФайлов;
	
	ПолноеИмяБраузераТестов = КонтекстЯдра.Объект.ПолноеИмяБраузераТестов;
	
	ПостроительДереваТестов = КонтекстЯдра.Плагин("ПостроительДереваТестов");
	ДеревоТестов = Неопределено;
	Для Сч = 1 По СтрЧислоСтрок(Путь) Цикл
		ФайлОбработки = Новый Файл(СтрПолучитьСтроку(Путь, Сч));
		ПроверитьКорректностьФайла(ФайлОбработки);
		
		Если ДеревоТестов = Неопределено Тогда
			ДеревоТестов = ПостроительДереваТестов.СоздатьКонтейнер(ФайлОбработки.Путь);
		КонецЕсли;
		
		ПодключитьВнешнююОбработку(КонтекстЯдра, ФайлОбработки);
		
		ИмяОбработки = "";
		МассивСообщений = Неопределено;
		
		// add_plus
		ПлагинНастройки = КонтекстЯдра.Плагин("Настройки");
		ПлагинНастройки.Инициализация(КонтекстЯдра);
		
		Настройки = ПлагинНастройки.ПолучитьНастройку(ФайлОбработки.ИмяБезРасширения);
		
		КонтейнерССервернымиТестамиОбработки = ЗагрузитьФайлНаСервере(ФайлОбработки.ПолноеИмя, ИмяОбработки, 
			КонтекстЯдра.Объект, МассивСообщений, Настройки);
		// add_plus
		КонтейнерСКлиентскимиТестамиОбработки = ЗагрузитьФайлНаКлиенте(ПостроительДереваТестов, ФайлОбработки, 
			КонтекстЯдра, ИмяОбработки);
		Если КонтейнерСКлиентскимиТестамиОбработки.Строки.Количество() > 0 Тогда
			КонтейнерССервернымиТестамиОбработки.Строки.Добавить(КонтейнерСКлиентскимиТестамиОбработки);
		КонецЕсли;
		Если КонтейнерССервернымиТестамиОбработки.Строки.Количество() > 0 Тогда
			ДеревоТестов.Строки.Добавить(КонтейнерССервернымиТестамиОбработки);
		КонецЕсли;
		
		КонтекстЯдра.ВывестиНакопленныеСообщенияОтСервераВРежимеОтладки(МассивСообщений);
	КонецЦикла;
	
	Возврат ДеревоТестов;
КонецФункции

&НаКлиенте
Функция ПолучитьКонтекстПоПути(КонтекстЯдра, Путь) Экспорт
	Перем Контекст;
	Если ЭтоПутьККлиентскомуКонтексту(Путь) Тогда
		Контекст = ПолучитьКлиентскийКонтекст(КонтекстЯдра, Путь);
	Иначе
		Контекст = ПолучитьСерверныйКонтекст(КонтекстЯдра, Путь);
	КонецЕсли;
	
	Возврат Контекст;
КонецФункции
// } Loader interface

&НаКлиенте
Функция ПолучитьКлиентскийКонтекст(КонтекстЯдра, Путь)
	ПрефиксПутейСФормами = ПрефиксПутейСФормами();
	ФайлОбработки = Новый Файл(Сред(Путь, СтрДлина(ПрефиксПутейСФормами) + 1));
	ПроверитьКорректностьФайла(ФайлОбработки);
	ПодключитьВнешнююОбработку(КонтекстЯдра, ФайлОбработки);
	
	ИмяОбработки = ФайлОбработки.ИмяБезРасширения;
	Если Объект.ИспользоватьПрямыеПутиФайлов Тогда
		ИмяОбработки = ПолучитьИмяОбработки(ФайлОбработки.ПолноеИмя);
	КонецЕсли;

	Контекст = ПолучитьФорму("ВнешняяОбработка." + ИмяОбработки + ".Форма", , ЭтаФорма, Новый УникальныйИдентификатор);
	Если ПеременнаяСодержитСвойство(Контекст, "ПутьКФайлуПолный") Тогда
		Контекст.ПутьКФайлуПолный = ФайлОбработки.ПолноеИмя;
	КонецЕсли;
	
	Возврат Контекст;
КонецФункции

&НаКлиенте
Функция ПолучитьСерверныйКонтекст(КонтекстЯдра, Путь)
	ФайлОбработки = Новый Файл(Путь);
	ПроверитьКорректностьФайла(ФайлОбработки);
	ПодключитьВнешнююОбработку(КонтекстЯдра, ФайлОбработки);
	
	ИмяОбработки = ФайлОбработки.ИмяБезРасширения;
	Если Объект.ИспользоватьПрямыеПутиФайлов Тогда
		ИмяОбработки = ПолучитьИмяОбработки(ФайлОбработки.ПолноеИмя);
	КонецЕсли;

	Контекст = КонтекстЯдра.ПолучитьОписаниеКонтекстаВыполнения(ИмяОбработки);
	
	Возврат Контекст;
КонецФункции

&НаКлиенте
Процедура ПроверитьКорректностьФайла(Файл)
	
	Если ЕстьПоддержкаАсинхронныхВызовов Тогда
		Возврат;
	КонецЕсли;
	
	Если Не Файл.Существует() Тогда
		ВызватьИсключение "Переданный файл не существует файл <" + Файл.ПолноеИмя + ">";
	КонецЕсли;
	Если Файл.ЭтоКаталог() Тогда
		ВызватьИсключение "Передан каталог вместо файла <" + Файл.ПолноеИмя + ">";
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ЗагрузитьФайлНаСервере(ПолныйПутьКОбработкеНаКлиенте, ИмяОбработки, Знач ОбъектКонтекстаЯдра, МассивСообщений, Настройки) // add_plus
	
	КонтекстЯдра = ПолучитьКонтекстЯдраНаСервере(ОбъектКонтекстаЯдра);
	
	ПостроительДереваТестов = КонтекстЯдра.СоздатьОбъектПлагина("ПостроительДереваТестов");
	ФайлОбработки = Новый Файл(ПолныйПутьКОбработкеНаКлиенте);
	ИмяОбработки = "";
	
	// add_plus	
	Контейнер = ЭтотОбъектНаСервере().ЗагрузитьФайл(ПостроительДереваТестов, ФайлОбработки, КонтекстЯдра, ИмяОбработки, Настройки);
	// add_plus
	
	МассивСообщений = ПолучитьСообщенияПользователю(Истина);
	
	Возврат Контейнер;
КонецФункции

&НаКлиенте
Функция ЗагрузитьФайлНаКлиенте(ПостроительДереваТестов, ФайлОбработки, КонтекстЯдра, ИмяОбработки)
	
	ЭтоФайлОтчета = (НРег(ФайлОбработки.Расширение) = ".erf");
	
	ЭтоАнглийский = ВключенаАнглийскаяЛокализация(); //Найти(ИмяОбработки, "DataProcessorObject") > 0;
	//ИмяОбработки	"ExternalDataProcessorObject.Тесты_ПарсерКоманднойСтроки"	String
	
	Если Не ЭтоАнглийский Тогда
		Если ЭтоФайлОтчета Тогда
			ФормаОбработки = ПолучитьФорму("ВнешнийОтчет." + ИмяОбработки + ".Форма");
		Иначе
			ФормаОбработки = ПолучитьФорму("ВнешняяОбработка." + ИмяОбработки + ".Форма");
		КонецЕсли;
	Иначе
		Если ЭтоФайлОтчета Тогда
			ФормаОбработки = ПолучитьФорму("ExternalReport." + ИмяОбработки + ".Форма");
		Иначе
			ФормаОбработки = ПолучитьФорму("ExternalDataProcessor." + ИмяОбработки + ".Форма");
		КонецЕсли;
	КонецЕсли;
	
	ЗаполнитьСвойствоПриНаличии(ФормаОбработки, "ПутьКФайлуПолный", ФайлОбработки.ПолноеИмя);
	
	Попытка
		Контейнер = ЗагрузитьТестыВНовомФормате_НаКлиенте(ПостроительДереваТестов, ФормаОбработки, ФайлОбработки, ИмяОбработки, КонтекстЯдра);
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		Если ЭтоНовыйФорматОбработки(ТекстОшибки) Тогда
			ВызватьИсключение;
		Иначе
			Контейнер = ЗагрузитьТестыВСтаромФормате_НаКлиенте(ПостроительДереваТестов, ФормаОбработки, ФайлОбработки, КонтекстЯдра);
		КонецЕсли;
	КонецПопытки;
	
	Возврат Контейнер;
КонецФункции

&НаКлиенте
Функция ЗагрузитьТестыВНовомФормате_НаКлиенте(ПостроительДереваТестов, ФормаОбработки, ФайлОбработки, ИмяОбработки, 
			КонтекстЯдра)
	ЗагружаемыйПуть = ФайлОбработки.ПолноеИмя;
	КэшПостроительДереваТестов = ПостроительДереваТестов;
	// add_plus Подменяем имя
	// КонтейнерТестов = ПостроительДереваТестов.СоздатьКонтейнер(ПрефиксПутейСФормами() + ИмяОбработки, ПостроительДереваТестов.Объект.ИконкиУзловДереваТестов.Форма); 
	КонтейнерТестов = ПостроительДереваТестов.СоздатьКонтейнер(ПрефиксПутейСФормами() + ФайлОбработки.ИмяБезРасширения, ПостроительДереваТестов.Объект.ИконкиУзловДереваТестов.Форма);
	// add_plus Подменяем имя
	Попытка
		ФормаОбработки.ЗаполнитьНаборТестов(ЭтаФорма, КонтекстЯдра);
	Исключение
		Инфо = ИнформацияОбОшибке();
		Если Инфо.ИмяМодуля = "ВнешняяОбработка.ЗагрузчикФайла.Форма.Форма.Форма" И
			(Инфо.Описание = "Слишком много фактических параметров" Или
			Инфо.Описание = "Too many actual parameters") И
			Найти(Инфо.ИсходнаяСтрока, "ФормаОбработки.ЗаполнитьНаборТестов(ЭтаФорма, КонтекстЯдра);") > 0
			Тогда
				
				ФормаОбработки.ЗаполнитьНаборТестов(ЭтаФорма);
			Иначе
				ВызватьИсключение;
			КонецЕсли;
	КонецПопытки;
	Результат = КонтейнерТестов;
	КонтейнерТестов = Неопределено;
	ТекущаяГруппа = Неопределено;
	
	Возврат Результат;
КонецФункции

&НаКлиенте
Функция ЭтоНовыйФорматОбработки(Знач ТекстОшибки)
	ЭтоНовыйФорматОбработки = Не ЕстьОшибка_МетодОбъектаНеОбнаружен(ТекстОшибки, "ЗаполнитьНаборТестов");
	
	Возврат ЭтоНовыйФорматОбработки;
КонецФункции

&НаКлиенте
Функция ЗагрузитьТестыВСтаромФормате_НаКлиенте(ПостроительДереваТестов, ФормаОбработки, ФайлОбработки, КонтекстЯдра)
	Попытка
		СписокТестов = ФормаОбработки.ПолучитьСписокТестов();
	Исключение
		Описание = ОписаниеОшибки();
		Если Найти(Описание, "Недостаточно фактических параметров") > 0 Тогда
			ВызватьИсключение "Старый формат тестов в обработке тестов <"+ФайлОбработки.ПолноеИмя+">."+Символы.ПС+
				"Метод ПолучитьСписокТестов сейчас не принимает параметров";
		КонецЕсли;
		
		Если Найти(Описание, "Метод объекта не обнаружен (ПолучитьСписокТестов)") = 0
			И Найти(Описание, "Object method not found (ПолучитьСписокТестов)") = 0 Тогда
			ВызватьИсключение Описание;
		КонецЕсли;
	КонецПопытки;
	СлучайныйПорядокВыполнения = Истина;
	Попытка
		СлучайныйПорядокВыполнения = ФормаОбработки.РазрешенСлучайныйПорядокВыполненияТестов();
	Исключение
	КонецПопытки;
	
	ИмяКонтейнера = ПрефиксПутейСФормами() + ФайлОбработки.ИмяБезРасширения;
	Путь = ПрефиксПутейСФормами() + ФайлОбработки.ПолноеИмя;
	Контейнер = ПолучитьКонтейнерДереваТестовПоСпискуТестовНаСервере(СписокТестов, ИмяКонтейнера, Путь,
		СлучайныйПорядокВыполнения, КонтекстЯдра.Объект);
	Контейнер.ИконкаУзла = ПостроительДереваТестов.Объект.ИконкиУзловДереваТестов.Форма;
	
	Возврат Контейнер;
КонецФункции

&НаСервере
Функция ПолучитьКонтейнерДереваТестовПоСпискуТестовНаСервере(СписокТестов, ИмяКонтейнера, Путь,
		СлучайныйПорядокВыполнения, Знач ОбъектКонтекстаЯдра)
	
	КонтекстЯдра = ПолучитьКонтекстЯдраНаСервере(ОбъектКонтекстаЯдра);
	
	ПостроительДереваТестов = КонтекстЯдра.СоздатьОбъектПлагина("ПостроительДереваТестов");
	Контейнер = ЭтотОбъектНаСервере().ПолучитьКонтейнерДереваТестовПоСпискуТестов(ПостроительДереваТестов, СписокТестов, ИмяКонтейнера, Путь, СлучайныйПорядокВыполнения);
	
	Возврат Контейнер;
КонецФункции

&НаКлиенте
Функция ЭтоПутьККлиентскомуКонтексту(Путь)
	ПрефиксПутейСФормами = ПрефиксПутейСФормами();
	Результат = (Найти(Путь, ПрефиксПутейСФормами) = 1);
	
	Возврат Результат;
КонецФункции

&НаКлиенте
Функция ПрефиксПутейСФормами()
	Возврат "УпрФорма # ";
КонецФункции

// { API нового формата
&НаКлиенте
Процедура СлучайныйПорядокВыполнения() Экспорт
	Если ЗначениеЗаполнено(КонтейнерТестов) Тогда
		КонтейнерТестов.СлучайныйПорядокВыполнения = Истина;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура СтрогийПорядокВыполнения() Экспорт
	Если ЗначениеЗаполнено(КонтейнерТестов) Тогда
		КонтейнерТестов.СлучайныйПорядокВыполнения = Ложь;

		ОстановитьВыполнениеПослеПаденияТестов();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПродолжитьВыполнениеПослеПаденияТеста() Экспорт
	Если ЗначениеЗаполнено(КонтейнерТестов) Тогда
		КонтейнерТестов.ПродолжитьВыполнениеПослеПаденияТеста = Истина;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОстановитьВыполнениеПослеПаденияТестов() Экспорт
	Если ЗначениеЗаполнено(КонтейнерТестов) Тогда
		КонтейнерТестов.ПродолжитьВыполнениеПослеПаденияТеста = Ложь;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура НачатьГруппу(Знач ИмяГруппы, Знач СтрогийПорядокВыполнения = Ложь) Экспорт
	ТекущаяГруппа = КэшПостроительДереваТестов.СоздатьКонтейнер(ИмяГруппы, КэшПостроительДереваТестов.Объект.ИконкиУзловДереваТестов.Группа);
	ТекущаяГруппа.Путь = ПрефиксПутейСФормами() + ЗагружаемыйПуть;
	ТекущаяГруппа.СлучайныйПорядокВыполнения = Не СтрогийПорядокВыполнения;
	КонтейнерТестов.Строки.Добавить(ТекущаяГруппа);
КонецПроцедуры

&НаКлиенте
Функция Добавить(Знач ИмяМетода, Знач Параметры = Неопределено, Знач Представление = "") Экспорт
	Если Не ЗначениеЗаполнено(Параметры) ИЛИ ТипЗнч(Параметры) <> Тип("Массив") Тогда
		Если ТипЗнч(Параметры) = Тип("Строка") И Представление = "" Тогда
			Представление = Параметры;
		КонецЕсли;
		Параметры = Неопределено;
	КонецЕсли;
	Элемент = КэшПостроительДереваТестов.СоздатьЭлемент(ПрефиксПутейСФормами() + ЗагружаемыйПуть, ИмяМетода, Представление);
	Если Параметры <> Неопределено Тогда
		Элемент.Параметры = Параметры;
	КонецЕсли;
	Если ЗначениеЗаполнено(ТекущаяГруппа) Тогда
		ТекущаяГруппа.Строки.Добавить(Элемент);
	Иначе
		КонтейнерТестов.Строки.Добавить(Элемент);
	КонецЕсли;
	
	Возврат Элемент;
КонецФункции

&НаКлиенте
Функция ДобавитьДеструктор(Знач ИмяМетодаДеструктора, Знач Представление = "") Экспорт
	ЭлементДеструктор = Добавить(ИмяМетодаДеструктора, Неопределено, Представление);
	Если ЗначениеЗаполнено(ТекущаяГруппа) Тогда
		ТекущаяГруппа.ЭлементДеструктор = ЭлементДеструктор;
	Иначе
		КонтейнерТестов.ЭлементДеструктор = ЭлементДеструктор;
	КонецЕсли;
	Возврат ЭлементДеструктор;
КонецФункции

&НаКлиенте
Функция ПараметрыТеста(Знач Парам1, Знач Парам2 = Неопределено, Знач Парам3 = Неопределено, Знач Парам4 = Неопределено, Знач Парам5 = Неопределено, Знач Парам6 = Неопределено, Знач Парам7 = Неопределено, Знач Парам8 = Неопределено, Знач Парам9 = Неопределено) Экспорт
	ВсеПараметры = Новый Массив;
	ВсеПараметры.Добавить(Парам1);
	ВсеПараметры.Добавить(Парам2);
	ВсеПараметры.Добавить(Парам3);
	ВсеПараметры.Добавить(Парам4);
	ВсеПараметры.Добавить(Парам5);
	ВсеПараметры.Добавить(Парам6);
	ВсеПараметры.Добавить(Парам7);
	ВсеПараметры.Добавить(Парам8);
	ВсеПараметры.Добавить(Парам9);
	
	ИндексСПоследнимПараметром = 0;
	Для Сч = 0 По ВсеПараметры.ВГраница() Цикл
		Индекс = ВсеПараметры.ВГраница() - Сч;
		Если ВсеПараметры[Индекс] <> Неопределено Тогда
			ИндексСПоследнимПараметром = Индекс;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	ПараметрыТеста = Новый Массив;
	Для Сч = 0 По ИндексСПоследнимПараметром Цикл
		ПараметрыТеста.Добавить(ВсеПараметры[Сч]);
	КонецЦикла;
	
	Возврат ПараметрыТеста;
КонецФункции
// } API нового формата

// { Helpers
&НаСервере
Функция ЭтотОбъектНаСервере()
	Возврат РеквизитФормыВЗначение("Объект");
КонецФункции

&НаКлиенте
Функция ЕстьОшибка_МетодОбъектаНеОбнаружен(Знач ТекстОшибки, Знач ИмяМетода)
	Результат = Ложь;
	Если Найти(текстОшибки, "Метод объекта не обнаружен (" + ИмяМетода + ")") > 0
		ИЛИ Найти(текстОшибки, "Object method not found (" + ИмяМетода + ")") > 0  Тогда
		Результат = Истина;
	КонецЕсли;
	
	Возврат Результат;
КонецФункции
// } Helpers

// Универсальная функция для проверки наличия 
// свойств у значения любого типа данных
// Переменные:
// 1. Переменная - переменная любого типа, 
// для которой необходимо проверить наличие свойства
// 2. ИмяСвойства - переменная типа "Строка", 
// содержащая искомое свойства
// 
&НаКлиентеНаСервереБезКонтекста
Функция ПеременнаяСодержитСвойство(Переменная, ИмяСвойства)
     // Инициализируем структуру для теста 
     // с ключом (значение переменной "ИмяСвойства") 
     // и значением произвольного GUID'а
     GUIDПроверка = Новый УникальныйИдентификатор;
     СтруктураПроверка = Новый Структура;
     СтруктураПроверка.Вставить(ИмяСвойства, GUIDПроверка);
     // Заполняем созданную структуру из переданного 
     // значения переменной
     ЗаполнитьЗначенияСвойств(СтруктураПроверка, Переменная);
     // Если значение для свойства структуры осталось 
     // NULL, то искомое свойство не найдено, 
     // и наоборот.
     Если СтруктураПроверка[ИмяСвойства] = GUIDПроверка Тогда
          Возврат Ложь;
     Иначе
          Возврат Истина;
     КонецЕсли;
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Процедура ЗаполнитьСвойствоПриНаличии(ОбъектЗаполнения, ИмяСвойство, ЗначениеСвойства)

	Если ПеременнаяСодержитСвойство(ОбъектЗаполнения, ИмяСвойство) Тогда
		ОбъектЗаполнения[ИмяСвойство] = ЗначениеСвойства;
	КонецЕсли;

КонецПроцедуры

&НаСервере
Функция ПолучитьКонтекстЯдраНаСервере(Знач ОбъектКонтекстаЯдра)
	
	// Получаем доступ к серверному контексту обработки с использованием 
	// полного имени метаданных браузера тестов. Иначе нет возможности получить
	// доступ к серверному контексту ядра, т.к. изначально вызов был выполнен на клиенте.
	// При передаче на сервер клиентский контекст теряется.
	КонтекстЯдра = Неопределено;
	МетаданныеЯдра = Метаданные.НайтиПоПолномуИмени(ПолноеИмяБраузераТестов);
	//ЭтоАнглийский = ВключенаАнглийскаяЛокализация();
	
	Если НЕ МетаданныеЯдра = Неопределено
		И Метаданные.Обработки.Содержит(МетаданныеЯдра) Тогда
		
		ИмяОбработкиКонтекстаЯдра = СтрЗаменить(ПолноеИмяБраузераТестов, "Обработка", "Обработки");
		ИмяОбработкиКонтекстаЯдра = СтрЗаменить(ИмяОбработкиКонтекстаЯдра, "DataProcessor", "DataProcessors");
		Выполнить("КонтекстЯдра = " + ИмяОбработкиКонтекстаЯдра + ".Создать()");
		
	Иначе
		ИмяОбработкиКонтекстаЯдра = СтрЗаменить(ПолноеИмяБраузераТестов, "ВнешняяОбработка", "ВнешниеОбработки");
		ИмяОбработкиКонтекстаЯдра = СтрЗаменить(ИмяОбработкиКонтекстаЯдра, "ExternalDataProcessor", "ExternalDataProcessors");
		ИмяОбработкиКонтекстаЯдра = СтрЗаменить(ИмяОбработкиКонтекстаЯдра, ".", Символы.ПС);
		МенеджерОбъектов = СтрПолучитьСтроку(ИмяОбработкиКонтекстаЯдра, 1);
		ИмяОбъекта = СтрПолучитьСтроку(ИмяОбработкиКонтекстаЯдра, 2);
		Выполнить("КонтекстЯдра = " + МенеджерОбъектов + ".Создать("""+ИмяОбъекта+""")");
	КонецЕсли;

	КонтекстЯдра.ИнициализацияНаСервере(ОбъектКонтекстаЯдра);
	
	Возврат КонтекстЯдра;
	
КонецФункции

// } Подсистема конфигурации xUnitFor1C

// { Вспомогательные методы
&НаКлиенте
Процедура ВыбратьПутьИнтерактивноЗавершение(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если ВыбранныеФайлы = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ДиалогВыбораТеста = ДополнительныеПараметры.ДиалогВыбораТеста;
	Результат = ДополнительныеПараметры.Результат;
	КонтекстЯдра = ДополнительныеПараметры.КонтекстЯдра;
	
	Если (ВыбранныеФайлы <> Неопределено) Тогда
		Для каждого ПолноеИмяФайла Из ДиалогВыбораТеста.ВыбранныеФайлы Цикл
			Результат.ДобавитьСтроку(ПолноеИмяФайла);
		КонецЦикла;
	КонецЕсли;
	Текст = Результат.ПолучитьТекст();
	
	Текст = Лев(Текст, СтрДлина(Текст) - 1);
	
	Описание = ОписаниеПлагина(КонтекстЯдра, КонтекстЯдра.Объект.ТипыПлагинов);
	Если ЕстьПоддержкаАсинхронныхВызовов Тогда
		Обр = Новый ОписаниеОповещения("ОкончаниеЗагрузкиТестов", ЭтаФорма);
		КонтекстЯдра.НачатьЗагрузкуТестов(Обр, Описание.Идентификатор, Текст);
	Иначе
		КонтекстЯдра.ЗагрузитьТесты(Описание.Идентификатор, Текст);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ОкончаниеЗагрузкиТестов(Результат, Параметры) Экспорт
КонецПроцедуры

&НаКлиенте
Процедура ПодключитьВнешнююОбработку(КонтекстЯдра, Знач ФайлОбработки)
	Если Не Объект.ИспользоватьПрямыеПутиФайлов Тогда
		КонтекстЯдра.ПодключитьВнешнююОбработку(ФайлОбработки);
	КонецЕсли;
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ЗафиксироватьОшибкуВЖурналеРегистрации(Знач Событие, Знач ОписаниеОшибки, ЭтоПредупреждение = Ложь)
	Уровень = ?(ЭтоПредупреждение, УровеньЖурналаРегистрации.Предупреждение, УровеньЖурналаРегистрации.Ошибка);
	ЗаписьЖурналаРегистрации(Событие, Уровень, , , ОписаниеОшибки);
КонецПроцедуры

&НаСервереБезКонтекста
Функция ВключенаАнглийскаяЛокализация()
	ВариантВстроенногоЯзыкаАнглийский = Ложь;
	Если Metadata.ScriptVariant = Metadata.ObjectProperties.ScriptVariant.English Или
			ТекущийЯзыкСистемы() = "en" Тогда
		
		ВариантВстроенногоЯзыкаАнглийский = Истина;
	КонецЕсли;
	
	Возврат ВариантВстроенногоЯзыкаАнглийский;
КонецФункции

&НаСервере
Функция ПолучитьИмяОбработки(Знач ПутьФайла)
	ИмяОбработки = "";
	ФайлОбработки = Новый Файл(ПутьФайла);
	ЭтотОбъектНаСервере().ПолучитьКонтекстОбработки(ФайлОбработки, ИмяОбработки);
	Возврат ИмяОбработки;
КонецФункции

// } Вспомогательные методы
