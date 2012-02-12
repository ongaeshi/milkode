require 'clockwork'
include Clockwork

every(1.minute, 'update') do
	  `milk git`
end
