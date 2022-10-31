### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ 32ac49cf-e34a-4b13-813d-c18434f74ca1
import Pkg

# ╔═╡ f4baacbb-a9d9-41b4-89e0-83c2ad56f3a9
Pkg.add("Bruno")

# ╔═╡ 12857ac1-e4f4-4a86-9f90-3a2c8df818bb
Pkg.add("Plots")

# ╔═╡ 2126ac89-0540-4276-9bb1-85de7f5d5a34
Pkg.add("CSV")

# ╔═╡ e78360a3-11cc-4b06-816b-380124311d45
Pkg.add("DataFrames")

# ╔═╡ a4afa53d-606d-41e6-a068-f0221f981eba
Pkg.add("ForecastEval")

# ╔═╡ 4ec82b5c-02b1-4cc3-8427-a3aaf6561e41
using CSV, Plots, DataFrames, Statistics, Distributions

# ╔═╡ 962982a6-c4dd-4ae9-8437-e224d705f088
using Bruno

# ╔═╡ ec2f77e4-941f-4b56-9384-97ffa51781f5
using ForecastEval

# ╔═╡ 9b40e379-6f1c-406a-bc78-af9ef3985425
md"## Tutorial on how to use Bruno package in Julia"

# ╔═╡ 59e926f9-96b0-4fac-b012-b8fb39584bc0
md" Note: If you ever have a question or need help with a function or command in this package, type ? to get the help prompt to come up. Then, 

# ╔═╡ a60b092b-3ef5-4f83-9d8e-e52ebb9e4a0a
md" ##### Importing needed packages."

# ╔═╡ 94418871-2f19-4716-90fc-74d2560d5e42
md" #### Loading in the data"

# ╔═╡ e7f13db8-e07b-4d78-b33c-7ffa085b3321
md" This example data set contains spot and futures prices for both heating oil and gasloine, as well as the three month treasury bill rate (repo_rate)."

# ╔═╡ 68e7d1d1-de8b-45d9-8dea-c63d5a135637
data=CSV.read("example_dataset.csv", DataFrame)

# ╔═╡ 55d9e32d-c03d-4113-ac85-380cb9b1e768
md" #### Extract spot and futures prices from the data frame."

# ╔═╡ 69c04528-9ed1-4537-8767-f290d022e2bf
spot_gas=data.gas_spot

# ╔═╡ ac8327d1-b4f6-4692-9c51-104cc1a8c4f5
futures_gas=data.gas_futures

# ╔═╡ 5e59a8ba-816d-4d14-864a-7f7086f4cd52
md" #### Plot the data"

# ╔═╡ 92e697ff-b966-4588-ad88-b0e2d4f4cd90
plot(spot_gas, label="Spot price of Gas, Oct 1991-Dec 2003")

# ╔═╡ d2c75067-cfb5-4a6c-8238-b08b1285a76f
plot(futures_gas, label="Futures price of gas, Oct 1991-Dec 2003")

# ╔═╡ a1051cfe-cb54-4e5f-b9de-92ed05ba1982
md" #### Using the bootstrap function to generate data." 

# ╔═╡ 00c559f3-31ed-48e0-bb71-c6e131a4805f
md" Here I'm using the stationary bootstrap, but you could use the moving block or circular bootstrap as well. Before applying the bootstrap, I subset the data to include spot gas price, futures gas price, and three month treasury bill rate only. Notice that the input data set should not be a data frame, but a matrix or an array. "

# ╔═╡ 2241266b-7bcb-4986-8a4b-8683348b9c30
boot_data=Matrix(data[:, 4:6])

# ╔═╡ 04d82b45-7b92-449a-a01c-8a36db6284f1
boot_setup=BootstrapInput(boot_data[:, 1], Stationary)

# ╔═╡ 2ecdbccb-28e7-4a97-9fb5-b2da4b04f095
# Generating bootstrapped data, 10,000 replications
bootstrapped_data=makedata(boot_setup, 10000)

# ╔═╡ 13a81ea7-a0ae-4250-ae5a-6ad24c18c4e8
#plot simulated price paths
plot(1:length(bootstrapped_data[:, 1]), bootstrapped_data[:, 1:100], title= "Price Path Simulation", legend=false)

# ╔═╡ bbb99591-20d7-4c5c-ac7c-140eadcb8078
md"#### Calculating volatility, given a set of prices"

# ╔═╡ d9554477-0cc8-4d2a-b710-d12629993c0f
md" For this particular example, I'm using the first 60 days of gas spot prices."

# ╔═╡ 1306d6cf-fbcb-454d-9905-1e949937344e
vol=Stock(spot_gas[1:60])

# ╔═╡ c13aa24c-4664-4a1c-a18f-c2d2ea9f8fa1
print(vol)

# ╔═╡ a415065a-2e67-47e1-8e5e-3bf2ab7f1741
md" Or, you can calculate volatility by calling it directly within the function. This is assuming I'm using spot prices for the entire time series, rather than just the first 60 days."

# ╔═╡ 82266f40-ba2a-46aa-9d54-4092566b67ee
s_gas=Stock(;prices=data[!, "gas_spot"], name="Gas Spot", volatility=(get_volatility(data[!, "gas_spot"])/sqrt(2)))

# ╔═╡ 9488e4a7-694f-45fc-91db-a792ed5aae44
md" ###### Pricing a European call option using Black Scholes. Assuming 1 year to maturity, a strike price of 0.52 and a risk free rate of 5%."

# ╔═╡ 0824efa6-fa47-4ec0-a091-995cdc3c6976
call=EuroCallOption(s_gas, 0.52; maturity=1, risk_free_rate=0.05)

# ╔═╡ 55ba196d-f223-41ea-be11-474772577e37
price!(call, BlackScholes)

# ╔═╡ 3a8e3129-04a6-4561-a7b4-b52ca2a6e377
md" I can also price a call using methods other than Black Scholes. For example, I could use the binomial option pricing model." 

# ╔═╡ 15f07e9e-f70e-4a3b-b231-86f0b65da1b7
price!(call, BinomialTree)

# ╔═╡ 285d6bba-7fef-472f-83d8-8fb84ec3c1a7
md" You could use these call prices to set up an options related strategy, and calculate profits from that strategy. For example, you could calculate and compare the profits from no hedge to delta hedging with no balancing and delta hedging with daily reblancing. However, for this simple example I'm basing the strategy on what MGRM actually did. MGRM was short forward contracts, and long futures contracts. I calcualted profits accordingly, and include them below. Profits are based on all ten contract types, and are calculated for the entire ten year period (Jan 1992-Dec 2001). "

# ╔═╡ 5909f258-a709-4efc-b720-57154b068e45
profits=CSV.read("rProfit_fixed.csv", DataFrame)

# ╔═╡ 6e917495-e636-4168-a168-44f9770ce107
md" ##### Converting profits to losses using the isoelastic utility function, and calculating loss differentials."

# ╔═╡ b10fc0fe-609f-4bd6-a2d5-91a68c613f43
md" Next, I calculate losses and loss differentials given profits. To do this, I'll need to define a few functions The first converts profits to losses using the isoelastic utility function. The inputs to the loss function are p, which represents profits, and gamma, which is the coefficient of relative risk aversion. In this example, I'm assuming risk neutrality, which means that gamma will be equal to 0. The second function, differentials, calculates the loss differentials from the losses. I'm assuming that the one-to-one hedge is the benchmark model, and that all other hedging strategies, which are fixed hedges from 0 to 0.95 by increments of 0.05, are the alternative models. In the differentials function, loss is the losses of the alternative models, benchmark represents the losses from the benchmark model, t is length of the hedging strategy in months, and m is the number of alternative models."

# ╔═╡ 5df5bdfc-0b37-4dbd-901a-efde442dbfd4
# writing function to convert profits to losses. P represents profits, and gamma the coefficient of relative risk aversion.
function loss(p,γ)
	t=size(p,1)
	m=size(p,2)
	loss=zeros(t,m)
	for i in 1:t
		for j in 1:m
			loss[i,j]=-(p[i,j]+0im^(1-γ))/(1-γ)
		end
	end
	return loss
	end

# ╔═╡ 536f5e09-d187-4ac3-8e07-6f1361e3e5fd
# writing function to calculate loss differentials. Loss differentials are input for SPA test.
function differentials(loss, benchmark, t, m)
	diff=zeros(t,m)
	for i in 1:t
		for j in 1:m
			diff[i,j]=loss[i,j]-benchmark[i,j] 
			# SPA test is set up for loss differentials to be calculated as alternative minus benchmark.
		end
	end
	return diff
end

# ╔═╡ 39d6bb6e-6333-40b4-8a46-db8dbd02f6af
# remove 1:1 hedge from profits dataframe and make it its own variable
models=profits[:, 1:20]

# ╔═╡ bfa0b59e-5b89-4294-9bad-9cc6052b13e4
benchmark=profits[:, 21]

# ╔═╡ 28c31e08-e070-4332-afb2-56042a86b9c9
# apply loss function to alternative models
p1=models

# ╔═╡ 576377de-259e-4de4-a746-e90d1662fc9c
γ=0

# ╔═╡ 952114b8-c195-4182-8196-a7a9ba2ce5fb
model_losses=loss(p1,γ)

# ╔═╡ e3ce9a6a-e55d-4ed7-92df-3b43e92cd7ce
# applying loss function to benchmark model
bm_losses=loss(benchmark,0)

# ╔═╡ 105d626a-daf6-472a-bb22-f9416eeae10a
# converting benchmark losses to matrix with repeating values.
# Done so that benchmark losses is same size as model losses. 
# This is needed in order to calculate loss differentials
m=size(models, 2)

# ╔═╡ d07943b7-4943-4aae-b0b2-68f2284ae988
bm=repeat(bm_losses, 1, m)

# ╔═╡ 2946c9e5-9af1-45bd-bc7a-9491d4fb9181
# Calculating loss differentials.
a=model_losses

# ╔═╡ 81f7cfc7-4e97-46ca-9c60-946e7763bed6
x=bm

# ╔═╡ aa5f5e92-2524-448b-87b4-0401edf97310
t=size(a,1)

# ╔═╡ 1eeee194-48a7-4489-9a57-fa09dd48e2ef
n=size(a, 2)

# ╔═╡ b52e16f1-f60b-4c89-a524-4ea5371b8b1b
ld=differentials(a, x, t, n)

# ╔═╡ b2fbad8f-291e-403b-ba0a-fe61b2875a2c


# ╔═╡ 5de4a794-f7d9-4758-9db5-25ed38d71c9f
md" ##### Running SPA test on loss differentials."

# ╔═╡ d028f8df-e76a-4036-a1be-b5d9d11aa08f
SPA_test=spa(ld)

# ╔═╡ d9c62edc-479a-4dc7-a9e4-8d6a79381c98
md" As can be seen from SPA test results, all p-values are greater than 0.10, which means that I fail to reject the null hypothesis. The null hypothesis is that the benchmark model is at least as good as the the alternative models. Therefore, since the one-to-one hedge is the benchmark, I conclude that the one-to-one hedge is not inferior to the other hedging strategies."

# ╔═╡ a0178e59-8c0a-47de-b279-8fcda4ea368f
md" ###### One final note: If you ever have a question or need help with a function or command in this package, type ? to get the help prompt to come up. Then type the name of the command or function and the documentation will display."

# ╔═╡ Cell order:
# ╠═9b40e379-6f1c-406a-bc78-af9ef3985425
# ╠═59e926f9-96b0-4fac-b012-b8fb39584bc0
# ╠═a60b092b-3ef5-4f83-9d8e-e52ebb9e4a0a
# ╠═32ac49cf-e34a-4b13-813d-c18434f74ca1
# ╠═f4baacbb-a9d9-41b4-89e0-83c2ad56f3a9
# ╠═12857ac1-e4f4-4a86-9f90-3a2c8df818bb
# ╠═2126ac89-0540-4276-9bb1-85de7f5d5a34
# ╠═e78360a3-11cc-4b06-816b-380124311d45
# ╠═a4afa53d-606d-41e6-a068-f0221f981eba
# ╠═4ec82b5c-02b1-4cc3-8427-a3aaf6561e41
# ╠═962982a6-c4dd-4ae9-8437-e224d705f088
# ╠═94418871-2f19-4716-90fc-74d2560d5e42
# ╠═e7f13db8-e07b-4d78-b33c-7ffa085b3321
# ╠═68e7d1d1-de8b-45d9-8dea-c63d5a135637
# ╠═55d9e32d-c03d-4113-ac85-380cb9b1e768
# ╠═69c04528-9ed1-4537-8767-f290d022e2bf
# ╠═ac8327d1-b4f6-4692-9c51-104cc1a8c4f5
# ╠═5e59a8ba-816d-4d14-864a-7f7086f4cd52
# ╠═92e697ff-b966-4588-ad88-b0e2d4f4cd90
# ╠═d2c75067-cfb5-4a6c-8238-b08b1285a76f
# ╠═a1051cfe-cb54-4e5f-b9de-92ed05ba1982
# ╠═00c559f3-31ed-48e0-bb71-c6e131a4805f
# ╠═2241266b-7bcb-4986-8a4b-8683348b9c30
# ╠═04d82b45-7b92-449a-a01c-8a36db6284f1
# ╠═2ecdbccb-28e7-4a97-9fb5-b2da4b04f095
# ╠═13a81ea7-a0ae-4250-ae5a-6ad24c18c4e8
# ╠═bbb99591-20d7-4c5c-ac7c-140eadcb8078
# ╠═d9554477-0cc8-4d2a-b710-d12629993c0f
# ╠═1306d6cf-fbcb-454d-9905-1e949937344e
# ╠═c13aa24c-4664-4a1c-a18f-c2d2ea9f8fa1
# ╠═a415065a-2e67-47e1-8e5e-3bf2ab7f1741
# ╠═82266f40-ba2a-46aa-9d54-4092566b67ee
# ╠═9488e4a7-694f-45fc-91db-a792ed5aae44
# ╠═0824efa6-fa47-4ec0-a091-995cdc3c6976
# ╠═55ba196d-f223-41ea-be11-474772577e37
# ╠═3a8e3129-04a6-4561-a7b4-b52ca2a6e377
# ╠═15f07e9e-f70e-4a3b-b231-86f0b65da1b7
# ╠═285d6bba-7fef-472f-83d8-8fb84ec3c1a7
# ╠═5909f258-a709-4efc-b720-57154b068e45
# ╠═6e917495-e636-4168-a168-44f9770ce107
# ╠═b10fc0fe-609f-4bd6-a2d5-91a68c613f43
# ╠═5df5bdfc-0b37-4dbd-901a-efde442dbfd4
# ╠═536f5e09-d187-4ac3-8e07-6f1361e3e5fd
# ╠═39d6bb6e-6333-40b4-8a46-db8dbd02f6af
# ╠═bfa0b59e-5b89-4294-9bad-9cc6052b13e4
# ╠═28c31e08-e070-4332-afb2-56042a86b9c9
# ╠═576377de-259e-4de4-a746-e90d1662fc9c
# ╠═952114b8-c195-4182-8196-a7a9ba2ce5fb
# ╠═e3ce9a6a-e55d-4ed7-92df-3b43e92cd7ce
# ╠═105d626a-daf6-472a-bb22-f9416eeae10a
# ╠═d07943b7-4943-4aae-b0b2-68f2284ae988
# ╠═2946c9e5-9af1-45bd-bc7a-9491d4fb9181
# ╠═81f7cfc7-4e97-46ca-9c60-946e7763bed6
# ╠═aa5f5e92-2524-448b-87b4-0401edf97310
# ╠═1eeee194-48a7-4489-9a57-fa09dd48e2ef
# ╠═b52e16f1-f60b-4c89-a524-4ea5371b8b1b
# ╠═b2fbad8f-291e-403b-ba0a-fe61b2875a2c
# ╠═5de4a794-f7d9-4758-9db5-25ed38d71c9f
# ╠═ec2f77e4-941f-4b56-9384-97ffa51781f5
# ╠═d028f8df-e76a-4036-a1be-b5d9d11aa08f
# ╠═d9c62edc-479a-4dc7-a9e4-8d6a79381c98
# ╠═a0178e59-8c0a-47de-b279-8fcda4ea368f
