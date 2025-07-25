﻿
// { Plugin interface
Функция ОписаниеПлагина(КонтекстЯдра, ВозможныеТипыПлагинов) Экспорт
	Результат = Новый Структура;
	Результат.Вставить("Тип", ВозможныеТипыПлагинов.ГенераторОтчета);
	Результат.Вставить("Идентификатор", Метаданные().Имя);
	Результат.Вставить("Представление", "Отчет о тестировании в формате JUnit.xml");
	Результат.Вставить("ПотоковыйВывод", Истина);
	Результат.Вставить("ФормироватьСводныйФайл", Ложь);

	Возврат Новый ФиксированнаяСтруктура(Результат);
КонецФункции

Процедура Инициализация(КонтекстЯдраПараметр) Экспорт
КонецПроцедуры
// } Plugin interface

// { Report generator interface
Функция СоздатьОтчет(КонтекстЯдра, РезультатыТестирования) Экспорт
	ПостроительДереваТестов = КонтекстЯдра.Плагин("ПостроительДереваТестов");
	ЭтотОбъект.ТипыУзловДереваТестов = ПостроительДереваТестов.ТипыУзловДереваТестов;
	ЭтотОбъект.СостоянияТестов = КонтекстЯдра.СостоянияТестов;
	Отчет = СоздатьОтчетНаСервере(РезультатыТестирования);

	Возврат Отчет;
КонецФункции

Функция СоздатьОтчетНаСервере(РезультатыТестирования) Экспорт
	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.УстановитьСтроку("UTF-8");
	ЗаписьXML.ЗаписатьОбъявлениеXML();

	ЗаписьXML.ЗаписатьНачалоЭлемента("testsuites");
	ЗаписьXML.ЗаписатьАтрибут("name", XMLСтрока(РезультатыТестирования.Имя));
	ЗаписьXML.ЗаписатьАтрибут("time", XMLСтрока(РезультатыТестирования.ВремяВыполнения));
	ЗаписьXML.ЗаписатьАтрибут("tests", XMLСтрока(РезультатыТестирования.КоличествоТестов));
	ЗаписьXML.ЗаписатьАтрибут("failures", XMLСтрока(РезультатыТестирования.КоличествоСломанныхТестов));
	ЗаписьXML.ЗаписатьАтрибут("errors", XMLСтрока(РезультатыТестирования.КоличествоОшибочныхТестов));
	ЗаписьXML.ЗаписатьАтрибут("skipped", XMLСтрока(РезультатыТестирования.КоличествоНеРеализованныхТестов));

	ВывестиДанныеОтчетаТестированияРекурсивно(ЗаписьXML, РезультатыТестирования);

	ЗаписьXML.ЗаписатьКонецЭлемента();

	СтрокаXML = ЗаписьXML.Закрыть();
	Отчет = Новый ТекстовыйДокумент;
	Отчет.ДобавитьСтроку(СтрокаXML);

	Возврат Отчет;
КонецФункции

Процедура ВывестиДанныеОтчетаТестированияРекурсивно(ЗаписьXML, РезультатыТестирования, ИмяРодителя = "")
	Если РезультатыТестирования.Тип = ТипыУзловДереваТестов.Контейнер Тогда
		ЗаписьXML.ЗаписатьНачалоЭлемента("testsuite");
		ЗаписьXML.ЗаписатьАтрибут("name", РезультатыТестирования.Имя);
		
		// add_plus Правильная иерархия отчета
		НужноОбъявитьКласс  = Истина;
		ИмяКласса 			= РезультатыТестирования.Имя;
		
		Для Каждого ЭлементКоллекции Из РезультатыТестирования.Строки Цикл
			
			Если ЭлементКоллекции.Тип <> ТипыУзловДереваТестов.Контейнер
				И НужноОбъявитьКласс Тогда
				
				ИмяРодителя_Мод = СтрЗаменить(ИмяРодителя, "УпрФорма # ", ""); 
				НужноОбъявитьКласс 	= Ложь;
				ИмяКласса			= "ДымовыеТесты_" + ИмяРодителя_Мод + "." + РезультатыТестирования.Имя;
			КонецЕсли;
			
			ВывестиДанныеОтчетаТестированияРекурсивно(ЗаписьXML, ЭлементКоллекции, ИмяКласса);
		КонецЦикла;		
		// add_plus
		
		ЗаписьXML.ЗаписатьКонецЭлемента();
		
	Иначе
		ВывестиРезультатЭлемента(ЗаписьXML, РезультатыТестирования, ИмяРодителя);
	КонецЕсли;
КонецПроцедуры

Процедура ВывестиРезультатЭлемента(ЗаписьXML, РезультатыТестирования, ИмяРодителя)
	ЗаписьXML.ЗаписатьНачалоЭлемента("testcase");
	ЗаписьXML.ЗаписатьАтрибут("classname", XMLСтрока(ИмяРодителя));
	ЗаписьXML.ЗаписатьАтрибут("name", XMLСтрока(РезультатыТестирования.Представление));
	ЗаписьXML.ЗаписатьАтрибут("time", XMLСтрока(РезультатыТестирования.ВремяВыполнения));

	Если РезультатыТестирования.Состояние = СостоянияТестов.Пройден Тогда
		ЗаписьXML.ЗаписатьАтрибут("status", "passed");
	ИначеЕсли РезультатыТестирования.Состояние = СостоянияТестов.НеРеализован Тогда
		СтатусJUnit = "skipped";
		ЗаписьXML.ЗаписатьАтрибут("status", СтатусJUnit);
		ЗаписьXML.ЗаписатьНачалоЭлемента(СтатусJUnit);
		ЗаписьXML.ЗаписатьКонецЭлемента();
	ИначеЕсли РезультатыТестирования.Состояние = СостоянияТестов.Сломан Тогда
		СтатусJUnit = "failure";
		ЗаписьXML.ЗаписатьАтрибут("status", СтатусJUnit);
		ЗаписьXML.ЗаписатьНачалоЭлемента(СтатусJUnit);
		Сообщение = УдалитьНедопустимыеСимволыXML(СообщениеОбОшибке(РезультатыТестирования));
		ЗаписьXML.ЗаписатьАтрибут("message", XMLСтрока(Сообщение));
		ЗаписьXML.ЗаписатьКонецЭлемента();
	ИначеЕсли РезультатыТестирования.Состояние = СостоянияТестов.НеизвестнаяОшибка Тогда
		СтатусJUnit = "error";
		ЗаписьXML.ЗаписатьАтрибут("status", СтатусJUnit);
		ЗаписьXML.ЗаписатьНачалоЭлемента(СтатусJUnit);
		Сообщение = УдалитьНедопустимыеСимволыXML(СообщениеОбОшибке(РезультатыТестирования));
		ЗаписьXML.ЗаписатьАтрибут("message", XMLСтрока(Сообщение));
		ЗаписьXML.ЗаписатьКонецЭлемента();
	КонецЕсли;
	ЗаписьXML.ЗаписатьКонецЭлемента();
КонецПроцедуры

Функция СообщениеОбОшибке(РезультатТестирования)
	
	Результат = РезультатТестирования.Сообщение 
				+ ?(ЗначениеЗаполнено(РезультатТестирования.ПодробноеСообщение)
						, Символы.ПС
							+ "------------------"
							+ Символы.ПС
							+ РезультатТестирования.ПодробноеСообщение
						, "");
				
	Возврат Результат;
	
КонецФункции

#Если ТолстыйКлиентОбычноеПриложение Тогда
Процедура Показать(Отчет) Экспорт
	Отчет.Показать();
КонецПроцедуры
#КонецЕсли

Процедура Экспортировать(Отчет, ПолныйПутьФайла) Экспорт
	Отчет.Записать(ПолныйПутьФайла);
КонецПроцедуры

// Процедура ЗаписатьРезультатТестаНаСервере(Знач РезультатТеста, Знач ПолныйПутьФайла) Экспорт
Функция ПолучитьРезультатТестаНаСервере(Знач РезультатТеста) Экспорт

	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.УстановитьСтроку("UTF-8");
	ЗаписьXML.ЗаписатьОбъявлениеXML();

	ЗаписьXML.ЗаписатьНачалоЭлемента("testsuites");
	ЗаписьXML.ЗаписатьАтрибут("name", 	  XMLСтрока(РезультатТеста.Родитель.Родитель.Имя));
	ЗаписьXML.ЗаписатьАтрибут("time", 	  XMLСтрока(РезультатТеста.ВремяВыполнения));
	ЗаписьXML.ЗаписатьАтрибут("tests", 	  XMLСтрока(1));
	ЗаписьXML.ЗаписатьАтрибут("failures", XMLСтрока(?(РезультатТеста.Состояние = СостоянияТестов.Сломан, 1, 0)));
	ЗаписьXML.ЗаписатьАтрибут("errors",   XMLСтрока(?(РезультатТеста.Состояние = СостоянияТестов.НеРеализован, 1, 0)));
	ЗаписьXML.ЗаписатьАтрибут("skipped",  XMLСтрока(?(РезультатТеста.Состояние = СостоянияТестов.НеизвестнаяОшибка, 1, 0)));

	ЗаписьXML.ЗаписатьНачалоЭлемента("testsuite");
	ЗаписьXML.ЗаписатьАтрибут("name", XMLСтрока(РезультатТеста.Родитель.Родитель.Имя));
	ЗаписьXML.ЗаписатьНачалоЭлемента("testsuite");
	ЗаписьXML.ЗаписатьАтрибут("name", XMLСтрока(РезультатТеста.Родитель.Имя));

	ВывестиРезультатЭлемента(ЗаписьXML, РезультатТеста, РезультатТеста.Родитель.Имя);

	ЗаписьXML.ЗаписатьКонецЭлемента();
	ЗаписьXML.ЗаписатьКонецЭлемента();

	ЗаписьXML.ЗаписатьКонецЭлемента();

	СтрокаXML = ЗаписьXML.Закрыть();
	Отчет = Новый ТекстовыйДокумент;
	Отчет.ДобавитьСтроку(СтрокаXML);

	// ИмяФайла = ПолучитьУникальноеИмяФайла(ПолныйПутьФайла);
	// Экспортировать(Отчет, ИмяФайла);
	Возврат Отчет;
КонецФункции
// } Report generator interface

// { Helpers
Функция УдалитьНедопустимыеСимволыXML(Знач Результат)
	Позиция = НайтиНедопустимыеСимволыXML(Результат);
	Пока Позиция > 0 Цикл
		Результат = Лев(Результат, Позиция - 1) + Сред(Результат, Позиция + 1);
		Позиция = НайтиНедопустимыеСимволыXML(Результат, Позиция);
	КонецЦикла;

	Возврат Результат;
КонецФункции

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

Функция ПолучитьУникальноеИмяФайла(Знач ИмяФайла)
	Файл = Новый Файл(ИмяФайла);
	ГУИД = Новый УникальныйИдентификатор;
	ИмяФайла = СтрШаблон_("%1-result.xml", ГУИД);
	ИмяФайла = СтрШаблон_("%1/%2", Файл.Путь, ИмяФайла);
	Возврат ИмяФайла;
КонецФункции
// } Helpers
