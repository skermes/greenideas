require './greenideas'

rule :drawme do
    circle
end

rule :drawmetwice do
    drawme
    drawme
end

rule :recurse do
    puts 'recursing'
    recurse
end

a = 0
b = 0
c = 0

rule :myshape do
    a += 1
    myshape
end

rule :myshape do
    b += 1
    myshape
end

rule :myshape, 0.8 do
    c += 1
    myshape
end

$debugging = false
draw :myshape
puts "a: #{a} b #{b} c #{c}"