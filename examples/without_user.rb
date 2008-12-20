require 'rsnipt'

public_snipts = Snipt.snipts
# => [SniptStruct, SniptStruct, ...]

public_ruby_snipts = Snipt.snipts(:ruby)
# => [SniptStruct, SniptStruct, ...]