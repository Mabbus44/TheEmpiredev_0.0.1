-- Remove vanilla technologies
for i, tech in pairs(data.raw["technology"]) do
	if not string.find(tech.name, "empire-") then
		tech.enabled = false
	end
end

