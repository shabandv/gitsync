///////////////////////////////////////////////////////////////////
//
// Выполняет синхронизацию хранилища 1С с Git 
//
// Представляет собой модификацию приложения gitsync от 
// команды oscript-library
//
///////////////////////////////////////////////////////////////////

#Использовать cmdline
#Использовать logos
#Использовать tempfiles

#Использовать "core"

///////////////////////////////////////////////////////////////////

Перем Лог;	 					// Лог
Перем ДополнительныеПараметры;	// Структура с набором дополнительных параметров

///////////////////////////////////////////////////////////////////

Процедура ВывестиВерсию()
	
	Сообщить("GitSync ver 1.2.2");
	
КонецПроцедуры // ВывестиВерсию()

Функция РазобратьАргументыКоманднойСтроки()
    
	Парсер = ПолучитьПарсерКоманднойСтроки();
    Возврат Парсер.Разобрать(АргументыКоманднойСтроки);

КонецФункции // РазобратьАргументыКоманднойСтроки

Функция ПолучитьПарсерКоманднойСтроки()
    
    Парсер = Новый ПарсерАргументовКоманднойСтроки();    
    МенеджерКомандПриложения.ЗарегистрироватьКоманды(Парсер);
    
    Возврат Парсер;
    
КонецФункции // ПолучитьПарсерКоманднойСтроки

Функция ВыполнениеКоманды()
	
	ВывестиВерсию();
	ПараметрыЗапуска = РазобратьАргументыКоманднойСтроки();
	
	Если ПараметрыЗапуска = Неопределено ИЛИ ПараметрыЗапуска.Количество() = 0 Тогда
		
		Лог.Ошибка("Некорректные аргументы командной строки");
        МенеджерКомандПриложения.ПоказатьСправкуПоКомандам();
        Возврат 1;

	КонецЕсли;

	УстановитьРежимОтладкиПриНеобходимости(ПараметрыЗапуска.ЗначенияПараметров);
	УстановитьРежимУдаленияВременныхФайлов(ПараметрыЗапуска.ЗначенияПараметров);
	УстановитьБазовыйКаталогВременныхФайлов(ПараметрыЗапуска.ЗначенияПараметров);

	КодВозврата = МенеджерКомандПриложения.ВыполнитьКоманду(ПараметрыЗапуска.Команда, ПараметрыЗапуска.ЗначенияПараметров, ДополнительныеПараметры);
	УдалитьВременныеФайлыПриНеобходимости();
	
	Возврат КодВозврата;

КонецФункции // ВыполнениеКоманды()

Процедура УдалитьВременныеФайлыПриНеобходимости()

	Если ДополнительныеПараметры.УдалятьВременныеФайлы Тогда

		ВременныеФайлы.Удалить();

	КонецЕсли;

КонецПроцедуры // УдалитьВременныеФайлыПриНеобходимости

Процедура УстановитьРежимОтладкиПриНеобходимости(Знач ПараметрыЗапуска)

	Если ПараметрыЗапуска["-verbose"] = "on" ИЛИ ПараметрыЗапуска["-debug"] = "on" Тогда

		Лог.УстановитьУровень(УровниЛога.Отладка);

	КонецЕсли;

КонецПроцедуры // УстановитьРежимОтладкиПриНеобходимости

Процедура УстановитьРежимУдаленияВременныхФайлов(Знач ПараметрыЗапуска)

	Если ПараметрыЗапуска["-debug"] = "on" Тогда

		ДополнительныеПараметры.УдалятьВременныеФайлы = Истина;

	КонецЕсли;

КонецПроцедуры // УстановитьРежимУдаленияВременныхФайлов

Процедура УстановитьБазовыйКаталогВременныхФайлов(Знач ПараметрыЗапуска)

	Если ЗначениеЗаполнено(ПараметрыЗапуска["-tempdir"]) Тогда

		БазовыйКаталог  = ПараметрыЗапуска["-tempdir"];
		Если Не (Новый Файл(БазовыйКаталог).Существует()) Тогда

			СоздатьКаталог(БазовыйКаталог);

		КонецЕсли;

		ВременныеФайлы.БазовыйКаталог = БазовыйКаталог;

	КонецЕсли;

КонецПроцедуры // УстановитьБазовыйКаталогВременныхФайлов

Процедура ТочкаВхода()
	
	ДополнительныеПараметры = Новый Структура;
	
	Лог = Логирование.ПолучитьЛог("oscript.app.gitsync");
	ДополнительныеПараметры.Вставить("УдалятьВременныеФайлы", Ложь);
	ДополнительныеПараметры.Вставить("Лог", Лог);
	
	Попытка
		
		ЗавершитьРаботу(ВыполнениеКоманды());

	Исключение
		
		Лог.КритичнаяОшибка(ОписаниеОшибки());
		ЗавершитьРаботу(МенеджерКомандПриложения.РезультатыКоманд().ОшибкаВремениВыполнения);

	КонецПопытки;
	
КонецПроцедуры // ТочкаВхода

///////////////////////////////////////////////////////////////////

ТочкаВхода();

// // Временный импорт 1commands прямо в корневом скрипте для обгода бага opm
// // https://github.com/oscript-library/opm/issues/41
// #Использовать 1commands





// ///////////////////////////////////////////////////////////////////
// // Прикладные процедуры и функции

// Процедура ВыполнитьОбработку(Знач Параметры)

// 	Если ТипЗнч(Параметры) = Тип("Структура") Тогда
// 		УстановитьРежимОтладкиПриНеобходимости(Параметры.ЗначенияПараметров);
// 		УстановитьРежимУдаленияВременныхФайлов(Параметры.ЗначенияПараметров);
// 		УстановитьБазовыйКаталогВременныхФайлов(Параметры.ЗначенияПараметров);

// 		ВыполнитьКоманду(Параметры);
// 	Иначе

// 		ВывестиВерсию();

// 		УстановитьРежимОтладкиПриНеобходимости(Параметры);
// 		УстановитьРежимУдаленияВременныхФайлов(Параметры);
// 		УстановитьБазовыйКаталогВременныхФайлов(Параметры);

// 		Синхронизировать(
// 			Параметры["ПутьКХранилищу"],
// 			Параметры["URLРепозитория"],
// 			Параметры["ЛокальныйКаталогГит"],
// 			Параметры["-email"],
// 			Параметры["-v8version"],
// 			Параметры["-minversion"],
// 			Параметры["-maxversion"],
// 			Параметры["-format"],
// 			Параметры["-branch"],
// 			0,
// 			Параметры["-limit"]
// 			);

// 	КонецЕсли;

// КонецПроцедуры

// Процедура ВыполнитьКоманду(Знач ОписаниеКоманды)

// 	Если ОписаниеКоманды.Команда <> "-version" Тогда
// 		ВывестиВерсию();
// 	КонецЕсли;

// 	Параметры = ОписаниеКоманды.ЗначенияПараметров;

// 		КлонироватьРепозитарий(Параметры);
// 	ИначеЕсли ОписаниеКоманды.Команда = "all" Тогда
// 		СинхронизироватьПоСпискуРепозитариев(Параметры);
// 	ИначеЕсли ОписаниеКоманды.Команда = "-version" Тогда
// 		ВывестиВерсиюКратко();
// 	ИначеЕсли ОписаниеКоманды.Команда = "export" Тогда
// 		ВыполнитьКомандуЭкспортИсходников(Параметры);
// 	Иначе
// 		ВызватьИсключение "Неизвестная команда: " + ОписаниеКоманды.Команда;
// 	КонецЕсли;

// КонецПроцедуры





// Процедура ВывестиВерсию()
// 	Сообщить("GitSync v" + Версия());
// 	Сообщить("");
// КонецПроцедуры

// Процедура ВывестиВерсиюКратко()
// 	Сообщить(Версия());
// КонецПроцедуры









// Процедура Синхронизировать(Знач ПутьКХранилищу,
// 			Знач URLРепозитория,
// 			Знач ЛокальныйКаталогГит = Неопределено,
// 			Знач ДоменПочты = Неопределено,
// 			Знач ВерсияПлатформы = Неопределено,
// 			Знач НачальнаяВерсия = 0,
// 			Знач КонечнаяВерсия = 0,
// 			Знач Формат = Неопределено,
// 			Знач ИмяВетки = Неопределено,
// 			Знач КоличествоКоммитовДоPush = 0,
// 			Знач Лимит = 0) Экспорт

// 	Лог.Информация("Начинаю синхронизацию хранилища 1С и репозитария GIT");

// 	Если ЛокальныйКаталогГит = Неопределено Тогда
// 		ЛокальныйКаталогГит = ТекущийКаталог();
// 	КонецЕсли;

// 	Если Формат = Неопределено Тогда
// 		Формат = РежимВыгрузкиФайлов.Авто;
// 	КонецЕсли;

// 	Если КоличествоКоммитовДоPush = Неопределено Тогда
// 		КоличествоКоммитовДоPush  = 0;
// 	КонецЕсли;

// 	Если НачальнаяВерсия = "" Тогда
// 		НачальнаяВерсия  = 0;
// 	КонецЕсли;

// 	Если КонечнаяВерсия = "" Тогда
// 		КонечнаяВерсия  = 0;
// 	КонецЕсли;

// 	Если Лимит = "" Тогда
// 		Лимит  = 0;
// 	КонецЕсли;


// 	Если ТипЗнч(КоличествоКоммитовДоPush) = Тип("Строка") Тогда
// 		КоличествоКоммитовДоPush = Число(КоличествоКоммитовДоPush);
// 	КонецЕсли;

// 	Если ИмяВетки = Неопределено Тогда
// 		ИмяВетки = "master";
// 	КонецЕсли;

// 	Лог.Отладка("ПутьКХранилищу = " + ПутьКХранилищу);
// 	Лог.Отладка("URLРепозитория = " + URLРепозитория);
// 	Лог.Отладка("ЛокальныйКаталогГит = " + ЛокальныйКаталогГит);
// 	Лог.Отладка("ДоменПочты = " + ДоменПочты);
// 	Лог.Отладка("ВерсияПлатформы = " + ВерсияПлатформы);
// 	Лог.Отладка("Формат = " + Формат);
// 	Лог.Отладка("ИмяВетки = " + ИмяВетки);


// 	Распаковщик = ПолучитьРаспаковщик();
// 	Распаковщик.ВерсияПлатформы = ВерсияПлатформы;
// 	Распаковщик.ДоменПочтыДляGitПоУмолчанию = ДоменПочты;

// 	Лог.Информация("Получение изменений с удаленного узла (pull)");
// 	КодВозврата = Распаковщик.ВыполнитьGitPull(ЛокальныйКаталогГит, URLРепозитория, ИмяВетки);
// 	Если КодВозврата <> 0 Тогда
// 		ВызватьИсключение "Не удалось получить изменения с удаленного узла (код: " + КодВозврата + ")";
// 	КонецЕсли;

// 	Лог.Информация("Синхронизация изменений с хранилищем");
// 	ВыполнитьЭкспортИсходников(Распаковщик, 
// 							ПутьКХранилищу, 
// 							ЛокальныйКаталогГит, 
// 							НачальнаяВерсия, 
// 							КонечнаяВерсия, 
// 							Формат, 
// 							КоличествоКоммитовДоPush, 
// 							URLРепозитория,
// 							Лимит);

// 	Лог.Информация("Отправка изменений на удаленный узел");
// 	КодВозврата = Распаковщик.ВыполнитьGitPush(ЛокальныйКаталогГит, URLРепозитория, ИмяВетки);
// 	Если КодВозврата <> 0 Тогда
// 		ВызватьИсключение "Не удалось отправить изменения на удаленный узел (код: " + КодВозврата + ")";
// 	КонецЕсли;

// 	Лог.Информация("Синхронизация завершена");

// КонецПроцедуры



// Процедура ВыполнитьКомандуЭкспортИсходников(Знач Параметры)



// КонецПроцедуры

// Функция ТребуетсяСинхронизироватьХранилище(Знач ФайлХранилища, Знач ЛокальныйКаталогГит) Экспорт

// 	Распаковщик = ПолучитьРаспаковщик();
// 	Возврат Распаковщик.ТребуетсяСинхронизироватьХранилищеСГит(ФайлХранилища, ЛокальныйКаталогГит);

// КонецФункции





// Процедура УдалитьВременныеФайлыПриНеобходимости()

// 	Если УдалятьВременныеФайлы Тогда
// 		ВременныеФайлы.Удалить();
// 	КонецЕсли;

// КонецПроцедуры







// Процедура СинхронизироватьПоСпискуРепозитариев(Знач Параметры)

// 	ИмяФайлаНастроек = Параметры["ПутьКНастройкам"];
// 	Если ИмяФайлаНастроек = Неопределено Тогда
// 		ВывестиСправкуПоКомандам("all");
// 		ЗавершитьСкрипт(1);
// 	КонецЕсли;

// 	Если Параметры["-log"] <> Неопределено Тогда
// 		Аппендер = Новый ВыводЛогаВФайл();
// 		Аппендер.ОткрытьФайл(Параметры["-log"]);
// 		Лог.ДобавитьСпособВывода(Аппендер);
// 		Раскладка = ЗагрузитьСценарий(ОбъединитьПути(ТекущийСценарий().Каталог, "log-layout.os"));
// 		Лог.УстановитьРаскладку(Раскладка);
// 	КонецЕсли;

// 	Интервал = 0;
// 	Если Параметры["-timer"] <> Неопределено Тогда
// 		Интервал = Число(Параметры["-timer"]);
// 	КонецЕсли;

// 	Контроллер = ЗагрузитьСценарий(ОбъединитьПути(ТекущийСценарий().Каталог, "multi-controller.os"));

// 	Пока Истина Цикл
// 		Контроллер.ВыполнитьСинхронизациюПоФайлуНастроек(ЭтотОбъект, ИмяФайлаНастроек, Параметры["-force"] = Истина);

// 		Если Интервал <= 0 Тогда
// 			Прервать;
// 		Иначе
// 			Лог.Информация("Ожидаем " + Интервал + " секунд перед новым циклом");
// 			Приостановить(Интервал * 1000);
// 		КонецЕсли;

// 	КонецЦикла;

// КонецПроцедуры





// Процедура ЗавершитьСкрипт(Знач КодВозврата)
// 	ИмяСтартовогоСкрипта = Новый Файл(СтартовыйСценарий().Источник).Имя;
// 	ИмяТекущегоСкрипта = Новый Файл(ТекущийСценарий().Источник).Имя;
// 	Если ИмяСтартовогоСкрипта = ИмяТекущегоСкрипта Тогда
// 		ЗавершитьРаботу(КодВозврата);
// 	Иначе
// 		ВызватьИсключение Новый ИнформацияОбОшибке("Завершаем работу скрипта с кодом возврата " + КодВозврата, Новый Структура("КодВозврата", КодВозврата));
// 	КонецЕсли;
// КонецПроцедуры

