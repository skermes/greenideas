# Methods to create and execute rules

$debugging = true
def debug(msg)
    if $debugging
        puts msg
    end
end

class Action
    def initialize(chance, action)
        @chance = chance
        @action = action
    end
    
    def chance
        return @chance
    end
    
    def action
        return @action
    end
end

class StackFrame
    def initialize(size, x, y, rotation, brightness, hue, saturation)
        @size = size
        @x = x
        @y = y
        @rotation = rotation
        @brightness = brightness
        @hue = hue
        @saturation = saturation
    end
    
    def size
        return @size
    end
    
    def x
        return @x
    end
    
    def y
        return @y
    end
    
    def rotation
        return @rotation
    end
    
    def brightness
        return @brightness
    end
    
    def hue
        return @hue
    end
    
    def saturation
        return @saturation
    end
    
    def to_s
        "StackFrame: s #{@size}; x #{@x}; y #{@y}; r #{@rotation}; b #{@brightness}; h #{@hue}; sat #{saturation}"
    end
end

$rule_index = { }
$MAX_DEPTH = 5
$stack = []

def choose_action(name)
    if (not $rule_index.has_key? name) or
       $rule_index[name].length == 0
        debug "rule #{name} does not exist in the index.  aborting."
        raise
    end
    
    weighted_options = $rule_index[name].select { |action| !action.chance.nil? }
    
    if weighted_options.length == 0
        return $rule_index[name][rand($rule_index[name].length)].action
    end
    
    weight_so_far = 0
    target = rand
    weighted_options.each do |option|
        if option.chance + weight_so_far >= target
            return option.action
        else
            weight_so_far += option.chance
        end
    end
    
    unweighted_options = $rule_index[name] - weighted_options
    if unweighted_options.length == 0
        debug "rule #{name} has weighted options that don't add to 1 and no unweighted options."
        raise
    end
    
    return unweighted_options[rand(unweighted_options.length)].action
end

def rule(name, chance=nil, &action)
    if $rule_index.has_key? name
        $rule_index[name].push Action.new(chance, action)
    else
        $rule_index[name] = [Action.new(chance, action)]
    end
    
    define_singleton_method name do |options={}|
        debug ""
        debug "running rule #{name}"
        debug "supplied options #{options}"
        
        
        if $stack.length <= $MAX_DEPTH            
            # The (somewhat arbitrary) semantics we're working with right now are
            # that size, x and y are multiplicative, while everything else is 
            # additive.
            parent_frame = $stack[-1]
            d_size = options[:size] || 1
            d_x = options[:x] || 1
            d_y = options[:y] || 1
            d_rot = options[:rotation] || 0
            d_bright = options[:brightness] || 0
            d_hue = options[:hue] || 0
            d_sat = options[:saturation] || 0
            new_frame = StackFrame.new(parent_frame.size * d_size,
                                       parent_frame.x * d_x,
                                       parent_frame.y * d_y,
                                       parent_frame.rotation * d_rot,
                                       parent_frame.brightness * d_bright,
                                       parent_frame.hue * d_hue,
                                       parent_frame.saturation * d_sat)
                                       
            debug "new frame:"            
            debug new_frame
            
            $stack.push new_frame
        
            choose_action(name).call
            
            $stack.pop
        end        
    end
end

def draw(rule)
    $stack = [StackFrame.new(200, 100, 100, 0, 0, 0, 0)]

    send rule
end

# Primitive drawing methods

rule :circle do
    puts 'drawing a circle'
end

rule :rectangle do
    puts 'drawing a rectangle'
end
