import React, { PropTypes } from 'react';
import _ from 'underscore';
import ChartJS from 'chart.js';

const styles = {
  height: 350,
};

class BarChart extends React.Component {
  constructor() {
    super();
    this.toggleChart = this.toggleChart.bind(this);
  }

  componentDidMount() {
    this.initChart();
  }

  componentDidUpdate() {
    this.countChart(this.props.data);
  }

  buildCountChart(data) {
    const result = [];
    const funders = _.uniq(_.pluck(data, 'funder'));
    _.each(funders, (funder, index) => {
      const monthCounts = _.chain(data)
                           .where({ funder })
                           .map(grant => ({
                             awardDate: parseInt(grant.award_date.slice(5, -3), 10),
                           }))
                           .countBy('awardDate')
                           .value();

      const monthsOfYear = _.object(_.range(1, 13), _.times(12, _.random.bind(_, 0, 0)));
      const months = _.toArray(Object.assign({}, monthsOfYear, monthCounts));

      const colours = ['255, 99, 132', '54, 162, 235', '255, 206, 86'];
      return result.push({
        label: funder,
        data: months,
        backgroundColor: `rgba(${colours[index]}, 0.2)`,
        borderColor: `rgba(${colours[index]}, 1)`,
        borderWidth: 1,
      });
    });
    return result;
  }

  buildAmountChart(data) {
    const result = [];
    const funders = _.uniq(_.pluck(data, 'funder'));
    _.each(funders, (funder, index) => {
      const monthAmounts = _.chain(data)
                            .where({ funder })
                            .map(grant => ({
                              awardMonth: parseInt(grant.award_date.slice(5, -3), 10),
                              amountAwarded: grant.amount_awarded,
                            }))
                            .groupBy('awardMonth')
                            .value();

      const monthsOfYear = _.object(_.range(1, 13), _.times(12, _.random.bind(_, 0, 0)));
      _.each(monthAmounts, arr => {
        _.each(arr, obj => {
          monthsOfYear[obj.awardMonth] += parseInt(obj.amountAwarded, 10);
        });
      });
      const months = _.toArray(monthsOfYear);

      const colours = ['255, 99, 132', '54, 162, 235', '255, 206, 86'];
      return result.push({
        label: funder,
        data: months,
        backgroundColor: `rgba(${colours[index]}, 0.2)`,
        borderColor: `rgba(${colours[index]}, 1)`,
        borderWidth: 1,
      });
    });
    return result;
  }

  initChart() {
    const chart = new ChartJS(document.getElementById('chart'), {
      type: 'bar',
      data: {
        labels: ['Jan', 'Feb', 'Mar',
                 'Apr', 'May', 'Jun',
                 'Jul', 'Aug', 'Sep',
                 'Oct', 'Nov', 'Dec'],
        datasets: [],
      },
      options: {
        title: {
          display: true,
          text: '2015 Grants', // TODO: get year from data
        },
        tooltips: {
          mode: 'label',
          multiKeyBackground: 'transparent',
        },
        scales: {
          yAxes: [{
            scaleLabel: {
              display: true,
              labelString: '# of grants',
            },
            ticks: {
              beginAtZero: true,
            },
          }],
        },
      },
    });
    this.setState({ chart });
  }

  countChart(data) {
    const chart = this.state.chart;
    chart.data.datasets = this.buildCountChart(data);
    chart.update();
  }

  amountChart(data) {
    const chart = this.state.chart;
    chart.data.datasets = this.buildAmountChart(data);
    chart.update();
  }

  toggleChart(event) {
    if (event.target.value > 0) {
      this.amountChart(this.props.data);
    } else {
      this.countChart(this.props.data);
    }
  }

  render() {
    return (
      <div>
        <div className="tiny ui buttons">
          <button className="ui button" value="0" onClick={this.toggleChart}>
            # of grants
          </button>
          <div className="or"></div>
          <button className="ui button" value="1" onClick={this.toggleChart}>
            £ of grants
          </button>
        </div>
        <canvas id="chart" style={styles}></canvas>
      </div>
    );
  }
}

BarChart.propTypes = {
  data: PropTypes.array.isRequired,
};

export default BarChart;
