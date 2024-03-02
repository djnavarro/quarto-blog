using JSON

dictionary = JSON.parsefile("praise.json"; dicttype=Dict{String, Vector{String}})

function praise(name)
    hey = rand(dictionary["exclamation"])
    sup = rand(dictionary["superlative"])
    adv = rand(dictionary["adverb"])
    "$hey $name you are $adv $sup"
end

function praise()
    hey = rand(dictionary["exclamation"])
    sup = rand(dictionary["superlative"])
    adv = rand(dictionary["adverb"])
    "$hey you are $adv $sup"
end
