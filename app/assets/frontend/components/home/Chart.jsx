import React, { PropTypes } from 'react';
import BarChart from './BarChart';
import PolarChart from './PolarChart';

const Chart = ({ data, type }) =>
  <div>
    {type === 'bar' ?
      <BarChart data={data} />
      :
      <PolarChart data={data} />}
  </div>;

Chart.propTypes = {
  data: PropTypes.array.isRequired,
  type: PropTypes.string.isRequired,
};

export default Chart;
