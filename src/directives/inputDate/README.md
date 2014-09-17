inputDate + angular bootstrap datepicker fork
(c) dhilt, 2014

please, look at original component:
#### http://angular-ui.github.io/bootstrap/

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


###  Feedback with parent (end-use) model

1. Component has an isolate scope. And there is no two-way binding between component date value and parent model date value.

2. Direct one-way binding arise from ng-model property. This is a parent model property where will commit data from component.

3. Component may know about external (parent model) value changes through special event firing. By this a special object with required data changing comes to component.


### Template usage example

```html
<input-date
    value="uiData.serviceDate"
    name="serviceDate"
    tabindex="5"
    autocommit="lostFocus, enter"
    update-from-ctrl="serviceDateUpdateFire"
    ng-disabled="readonly"
    ng-class="{'input-group-invalid': isFormValid}">
</input-date>
```

--------------------------------------------------

### Additional

1. There is no need to inject additional code in your controller. You may deal with "value"-property of <input-date> as if it was "ng-model"-property of simple <input>. By the way you have to keep in mind that the component has an isolated scope and feedback with end-use model has implement limitations.

2. About two-way binding emulation. This is an example of external date changing (via "update-from-ctrl"-property) when UI has to allow to clear date:
 	```html
		$scope.clearDate = function () {
			$scope.serviceDateUpdateFire = {
				value: ""
			}
		};
	```

3. Validation logic is injected in components code. Each time the value is commiting there calling $setValidity method on parent scope  (specifically on a form element of parent scope, which is relevant to "name"-propery):
	```html
		$setValidity("dateValidator", isValid)
	```
, where isValid has a boolean type.

4. Autocommit by debounced input may configurate by delay param. There is syntax:
	```html
		autocommit="lostFocus, debouncedInput(500)"
	```
Thus commit by input will be delayed on 0.5 sec from the moment of last text-input changing.



--------------------------------------------------
