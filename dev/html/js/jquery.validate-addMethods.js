jQuery.validator.addMethod("qname", function(value, element) {
	return this.optional(element) || /^[a-z0-9_\-]+$/i.test(value);
}, "Please enter a value with a valid syntax");

jQuery.validator.addMethod("fpath", function(value, element) {
	return this.optional(element) || /^(\/[^\/]+)+\.\w+$/i.test(value);
}, "Please enter a value with a valid syntax");