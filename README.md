bayesocampus
============

<a href="http://payload72.cargocollective.com/1/8/260757/3749466/Henkka_maalaus-9.jpg">
    <img src="http://payload72.cargocollective.com/1/8/260757/3749466/Henkka_maalaus-9.jpg" width="364px" height="300" alt="thinking rat"
         title="&quot;I was going to tell a joke about my epistemological skepticism, but then I realized I don't know any.&quot;" align="right" />
</a>

~~_a cauldron of Bayesian witchcraft for rat mind-reading_~~

_a sandbox for fully-Bayesian neural decoding_

This code is maintained by Luke Arend and the members of the Johnson laboratory at Bethel University.

The codebase contains utilities for building tuning curves from raw spike data, visualizing the encoding model, and performing Bayesian neural decoding. This can be done in a stimulus space of an arbitrary number of dimensions. The code is intended to run in [MATLAB](https://www.mathworks.com/product/ltc/matlab.html) (written in version 2016a).

Image: "Thinking Rat" by [Henriikka Pöllänen](http://cargocollective.com/henriikkapollanen).

Getting set up
--------------

To get started, [clone](https://help.github.com/articles/cloning-a-repository/) this repository to your local machine.

Acquire a data set, and run _sandbox.m_ to start playing immediately!

Loading the data
----------------

Loading the neural data from a recording session assumes an Eichenbaum-style data file which contains at least the following fields:

* _unitdata_: 1 x 1 struct with two fields:
	* _units_: 1 x K struct where each cell has two fields and K is the number of units:
		* _name_: unit name.
		* _ts_: s x 1 array containing spike timestamps for s spikes.
	* _rawLEDs_: M x N array containing ground-truth stimulus data, where M is the number of samples and N is the number of stimuli recorded (dimensionality of the stimulus space).

Use the function _load\_data\_xy()_ to load x-y neural data.

Building tuning curves
----------------------

Use _build\_tuning\_curves()_ to construct tuning curves from neural data. This can build tuning curves either according to the Poisson encoding model (a simple estimate of the mean firing rate at each location) or the negative binomial encoding model (a sequential Bayesian estimate of a distribution over firing rate, using a gamma-distributed prior).

For more theory and detail on this method, see [manuscript in progress].

Computing information content for tuning curves
-----------------------------------------------

Use _get\_IC\_curves()_ to compute an information content map for a tuning curve or set of tuning curves. As a measure of information content at each location, this finds the KL divergence between the posterior over firing rate at that location and the posterior if firing rate is averaged across location.

Note that this can only be used on Bayesian tuning curves (those generated under the negative binomial encoding model).

Visualizing curves
------------------

Use _plot\_curves()_ to visualize a set of tuning curves, information content curves, or decoded posterior distributions.

Decoding neural activity
------------------------

Use _bayesian\_decode()_ to perform Bayesian decoding on spiking data. This produces a posterior distribution over stimulus space for each decoding timestep. This function accepts either Poisson- or negative binomial-based tuning curves.
