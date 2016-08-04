import _ from 'underscore';
import ChartJS from 'chart.js';

const counters = {
  animals: 0, buildings: 0, care: 0, crime: 0, disabilities: 0,
  disasters: 0, education: 0, environment: 0, ethnic: 0, exploitation: 0,
  food: 0, housing: 0, mental: 0, organisation: 0, organisations: 0,
  orientation: 0, physical: 0, poverty: 0, public: 0, refugees: 0,
  relationship: 0, religious: 0, services: 0, unemployed: 0, water: 0,
};

const prettyLabels = [
  'Animals and Wildlife', 'Buildings and Places', 'Care',
  'Crime', 'Disabilities',
  'Disasters', 'Education', 'Climate and the environment',
  'Ethnic groups',
  'Exploitation',
  'Food access', 'Housing/shelter',
  'Mental diseases or disorders', 'This organisation', 'Other organisations',
  'Sexual orientation', 'Physical diseases or disorders',
  'Income poverty', 'The general public',
  'Refugees and asylum seekers',
  'Family/relationship challenges',
  'Religious/spiritual beliefs',
  'The armed or rescue services',
  'Unemployment', 'Water/sanitation access',
];

const descriptiveLabels = [
  'Animals and Wildlife', 'Buildings and Places', 'People in, leaving, or providing care',
  'People affected or involved with crime', 'People with disabilities',
  'People affected by disasters', 'People in education', 'Climate and the environment',
  'People from a specific ethnic background',
  'People at risk of sexual exploitation, trafficking, forced labour, or servitude',
  'People with food access challenges', 'People with housing/shelter challenges',
  'People with mental diseases or disorders', 'This organisation', 'Other organisations',
  'People with a specific sexual orientation', 'People with physical diseases or disorders',
  'People facing income poverty', 'The general public',
  'People who are refugees and asylum seekers',
  'People with family/relationship challenges',
  'People with specific religious/spiritual beliefs',
  'People involved with the armed or rescue services',
  'People who are unemployed', 'People with water/sanitation access challenges',
];

class BarChart extends React.Component {
  componentDidMount() {
    this.initChart();
  }

  componentDidUpdate() {
    this.countChart(this.props.data);
  }

  buildCountChart(data) {
    const result = [];
    _.each(_.uniq(_.pluck(data, 'funder')), (funder, index) => {
      const funderLabels = Object.assign({}, counters);
      let res = [];
      const funderGrants = _.chain(data).where({ funder }).value();

      _.each(funderGrants, (grant) => {
        res.push(_.uniq(_.pluck(grant.beneficiaries.beneficiaries, 'name')));
      });
      res = _.flatten(res);

      _.each(res, (i) => funderLabels[i]++);
      _.map(funderLabels, (v, k) => {
        funderLabels[k] = v / funderGrants.length;
      });

      const colours = ['247, 186, 14', '66, 176, 193', '218, 93, 57'];
      return result.push({
        label: funder,
        data: _.values(funderLabels),
        backgroundColor: `rgba(${colours[index]}, 0.4)`,
        borderColor: `rgba(${colours[index]}, 0.8)`,
        borderWidth: 1,
      });
    });
    return result;
  }

  initChart() {
    const chart = new ChartJS(document.getElementById(this.props.element), {
      type: 'horizontalBar',
      data: {
        labels: prettyLabels,
        datasets: [],
      },
      options: {
        maintainAspectRatio: false,
        tooltips: {
          mode: 'label',
          multiKeyBackground: 'transparent',
          callbacks: {
            title: (tooltip) => `${descriptiveLabels[tooltip[0].index]}`,
            label: (tooltip, data) => {
              const datasetLabel = data.datasets[tooltip.datasetIndex].label;
              const value = parseInt(
                data.datasets[tooltip.datasetIndex].data[tooltip.index] * 100, 10);
              return `${datasetLabel}: ${value}%`;
            },
          },
        },
        scales: {
          xAxes: [{
            scaleLabel: {
              display: true,
              labelString: '% of grants in 2015',
            },
            ticks: {
              beginAtZero: true,
              min: 0,
              max: 1,
              callback: value => `${parseInt(value * 100, 10)}%`,
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

  render() {
    return (
      <canvas id={this.props.element}></canvas>
    );
  }
}

BarChart.propTypes = {
  element: React.PropTypes.string.isRequired,
  data: React.PropTypes.array.isRequired,
};

export default BarChart;
