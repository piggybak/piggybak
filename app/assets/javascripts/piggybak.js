var tax_total = 0;
var geodata;

$(function() {
	piggybak.populate_geodata();
	piggybak.initialize_listeners();
	piggybak.update_shipping_options($('#piggybak_order_shipping_address_attributes_state_id'));
	piggybak.update_tax();
});

var piggybak = {
	populate_geodata: function() {
		$.ajax({
			url: geodata_lookup,
			cached: false,
			dataType: "JSON",
			success: function(data) {
				geodata = data;
			}
		});
	},
	update_state_option: function(type, block) {
		var country_field = $('#piggybak_order_' + type + '_address_attributes_country_id');
		var country_id = country_field.val();
		var new_field;

		if(geodata.countries["country_" + country_id].length > 0) {
			new_field = $('<select>');
			$.each(geodata.countries["country_" + country_id], function(i, j) {
				new_field.append($('<option>').val(j.id).html(j.name));
			});	
		} else {
			new_field = $('<input>');
		}
		var old_field = $('#piggybak_order_' + type + '_address_attributes_state_id');
		new_field.attr('name', old_field.attr('name'));
		new_field.attr('id', old_field.attr('id'));
		old_field.replaceWith(new_field);

		if(block) {
			block();
		}
		return;
	},
	initialize_listeners: function() {
		$('#piggybak_order_shipping_address_attributes_country_id').change(function() {
			piggybak.update_state_option('shipping');
		});
		$('#piggybak_order_billing_address_attributes_country_id').change(function() {
			piggybak.update_state_option('billing');
		});
		$('#piggybak_order_shipping_address_attributes_state_id').change(function() {
			piggybak.update_shipping_options($(this));
		});
		$('#piggybak_order_billing_address_attributes_state_id').change(function() {
			piggybak.update_tax();
		});
		$('#shipping select').change(function() {
			piggybak.update_totals();
		});
		$('#shipping_address #copy').click(function() {
			piggybak.copy_from_billing();
			return false;
		});
		return;
	},
	copy_from_billing: function() {
		$('#billing_address input').each(function(i, j) {
			var id = $(j).attr('id').replace(/billing_address/, 'shipping_address');
			$('#' + id).val($(j).val());	
		});
		var country = $('#piggybak_order_billing_address_attributes_country_id').val();
		$('#piggybak_order_shipping_address_attributes_country_id').val(country);
		piggybak.update_state_option('shipping', function() {
			var state = $('#piggybak_order_billing_address_attributes_state_id').val();
			$('#piggybak_order_shipping_address_attributes_state_id').val(state);
		});
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
		var shipping_total = 0;
		if($('#shipping select option:selected').length) {
			shipping_total = $('#shipping select option:selected').data('rate');
		}
		$('#shipping_total').html('$' + shipping_total.toFixed(2));
		var order_total = subtotal + tax_total + shipping_total;
		$('#order_total').html('$' + order_total.toFixed(2));	
	}
};
