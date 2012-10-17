var geodata;

var piggybak_states = {
	initialize_listeners: function() {
		$('#piggybak_order_shipping_address_attributes_country_id').change(function() {
			piggybak_states.update_state_option('shipping');
		});
		$('#piggybak_order_billing_address_attributes_country_id').change(function() {
			piggybak_states.update_state_option('billing');
		});
		return;
	},
	populate_geodata: function() {
		$.ajax({
			url: geodata_lookup,
			cached: false,
			dataType: "JSON",
			success: function(data) {
				geodata = data;
				piggybak_states.update_state_option('shipping');
				piggybak_states.update_state_option('billing');
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
		new_field.attr('name', old_field.attr('name')).attr('id', old_field.attr('id'));
		if(old_field.prop('tagName') == new_field.prop('tagName')) {
			new_field.val(old_field.val());
		}
		old_field.replaceWith(new_field);

		if(block) {
			block();
		}
		return;
	}
};

$(function() {
	piggybak_states.populate_geodata();
	piggybak_states.initialize_listeners();
});

