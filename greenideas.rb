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

$rule_index = { }

$MAX_DEPTH = 30
$depth_tracker = { }

def choose_action(name)
    if (not $rule_index.has_key? name) or
       $rule_index[name].length == 0
        debug "rule #{name} does not exist in the index.  aborting."
        raise
    end
    
    weighted_options = $rule_index[name].select { |action| !action.chance.nil? }
                                        .sort { |a, b| a.chance <=> b.chance }
    
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
    $depth_tracker[name] = 0
    
    if $rule_index.has_key? name
        $rule_index[name].push Action.new(chance, action)
    else
        $rule_index[name] = [Action.new(chance, action)]
    end
    
    define_singleton_method name do
        debug "running rule #{name}"        
        
        if $depth_tracker[name] <= $MAX_DEPTH
            $depth_tracker[name] += 1
            choose_action(name).call
        end        
    end
end

def draw(rule)
    $depth_tracker.each_key { |key| $depth_tracker[key] = 0 }

    send rule
end

# Primitive drawing methods

rule :circle do
    puts 'drawing a circle'
end

rule :rectangle do
    puts 'drawing a rectangle'
end
