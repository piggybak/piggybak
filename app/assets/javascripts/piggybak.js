var tax_total = 0;

$(function() {
	piggybak.update_shipping_options($('#piggybak_order_shipping_address_attributes_state_id'));
	piggybak.initialize_listeners();
	piggybak.update_tax();
});

var piggybak = {
	initialize_listeners: function() {
		$('#piggybak_order_shipping_address_attributes_state_id').change(function() {
			piggybak.update_shipping_options($(this));
		});
		$('#piggybak_order_billing_address_attributes_state_id').change(function() {
			piggybak.update_tax();
		});
		$('#shipments select').change(function() {
			piggybak.update_totals();
		});
		return;
	},
	update_shipping_options: function(field) {
		var shipping_field = $('#piggybak_order_shipments_attributes_0_shipping_method_id');
		shipping_field.hide();
		var shipping_data = {};
		$('#shipping_address input, #shipping_address select').each(function(i, j) {
			var id = $(j).attr('id');
			id = id.replace("piggybak_order_shipping_address_attributes_", '');
			shipping_data[id] = $(j).val();	
		});
		$.ajax({
			url: shipping_lookup,
			cached: false,
			data: shipping_data,
			dataType: "JSON",
			success: function(data) {
				shipping_field.find('option').remove();
				$.each(data, function(i, j) {
					shipping_field.append($('<option>').html(j.label).val(j.id).data('rate', j.rate));
				});
				shipping_field.show();
				piggybak.update_totals();
			}
		});
	},
	update_tax: function(field) {
		var billing_data = {};
		$('#billing_address input, #billing_address select').each(function(i, j) {
			var id = $(j).attr('id');
			id = id.replace("piggybak_order_billing_address_attributes_", '');
			billing_data[id] = $(j).val();	
		});
		$.ajax({
			url: tax_lookup,
			cached: false,
			data: billing_data,
			dataType: "JSON",
			success: function(data) {
				tax_total = data.tax;
				piggybak.update_totals();
			}
		});
	},
	update_totals: function() {
		var subtotal = $('#subtotal_total').data('total');
		$('#tax_total').html('$' + tax_total.toFixed(2));
		var shipping_total = $('#shipments select option:selected').data('rate');
		$('#shipping_total').html('$' + shipping_total.toFixed(2));
		var order_total = subtotal + tax_total + shipping_total;
		$('#order_total').html('$' + order_total.toFixed(2));	
	}
};
