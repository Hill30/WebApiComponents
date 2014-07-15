inputDate + datepicker
(c) dhilt, 2014

--------------------------------------------------

### Component behaviour

1.  Keyboard only input.
	+ 1.1. Keyboard input in defined format without datepicker popup.
	+ 1.2. Autocommit (saving input value in model) in 4 modes:
		- immediate save in response to text-input contents changing (input);
		- debounced save in response to text-input contents changing (debouncedInput);
		- immediate save in response to text-input lost focus (lostFocus);
		- immediate save in response to ENTER key pressing (enter)
	+ 1.3. Autocommit-modes can be combined.
	+ 1.4. If there's no autocommit mode, lostFocus will be mode by default.

2. Work with popup (datepicker).
	+ 2.1. Popup shows only after calendar icon click.
	+ 2.2. Popup closes by second click on calendar icon or by click out of popup.
	+ 2.3. Popup closes by pick a date within popup.
	+ 2.4. Picked date gets into a text-input in defined format.
	+ 2.5. Popup closes by ESC key pressing. Date will not commit into text-input. Focus remains at text-input.
	+ 2.6. Popup closes by TAB key pressing. Date will not commit into text-input. Focus jupms on control next to date text-input (as if tab-event bubbles).
	+ 2.7. There is months/years navigation by LEFT/RIGHT key pressing within popup.
	+ 2.8. Click on "Today" button leads to pick (and commit) today date and popup close.

3. Feedback with parent (end-use) model.
	+ 3.1. Component has an isolate scope. And there is no two-way binding between component date value and parent model date value.
	+ 3.2. Direct one-way binding arise from ng-model property. This is a parent model property where will commit data from component.
	+ 3.3. Component may know about external (parent model) value changes through special event firing. By this a special object with required data changing comes to component.
	+ 3.4. Also component has subscription on ng-disabled.

--------------------------------------------------

### Пример использования директивы в шаблоне (для serviceTracker'а)

```html
<input-date
    value="overrides.serviceDate"
    name="serviceDate"
    tabindex="5"
    autocommit="lostFocus, enter"
    update-from-ctrl="serviceDateUpdateFire"
    ng-disabled="readonly"
    ng-class="{'input-group-invalid': form.serviceDate.$error.dateValidator && isFormSubmited}"
</input-date>
```

--------------------------------------------------

### Примечания

1. В контроллере никакого дополнительного кода не нужно. Можно работать со значением ("value") <input-date> так, как если бы это было бы "ng-model" простого <input>. Оданко, следует помнить, что scope input-date изолирован и обратная связь с моделью конечного назначения очень ограничена.

2. Модель конечного назначения сообщает компоненту inputDate о изменении значения путем создания/изменения обекта, указанного через свойство "update-from-ctrl". Синтаксис следующий:

```html
	serviceDateUpdateFire = {
		value: ""
	}
```

конкретно этот пример актуален, когда UI должен позволять очищать дату.

3. Валидация даты по формату в настоящей реализации внесена в код директивы (соответственно директива dateValidator больше не нужна; предлагается в дальнейшем генерализовать валидацию полей ввода путем введения универсального validationService). Всякий раз по записи значения в модель конечного назначения, на scope'е этой модели (а точнее на элементе формы этого scope'а, соответствующем параметру "name") вызывается следующий метод:

```html
	$setValidity("dateValidator", isValid)
```

, где isValid - имеет тип boolean. При необходимости наименование валидатора можно параметризировать, чтобы оно также задавалось декларативно через шаблон.

4. Autocommit по отложенному вводу может конфигурироваться параметром задержки. Для этого реализован следующий синтаксис:

```html
	autocommit="lostFocus, debouncedInput(500)"
```

Таким образом commit по вводу будет откладываться на полсекунды от момента последнего изменения textinput'а.



--------------------------------------------------
