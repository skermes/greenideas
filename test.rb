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
    rectangle
    a += 1
    myshape
end

rule :myshape do
    circle
    b += 1
    myshape
end

rule :myshape, 0.8 do
    c += 1
    myshape
end

rule :smaller_circle do
    circle
    smaller_circle size: 0.7
end

$debugging = true
draw :smaller_circle
