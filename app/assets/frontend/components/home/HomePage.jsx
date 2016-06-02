import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import * as grantActions from '../../actions/grantActions';
import FunderList from './FunderList';
import _ from 'underscore';
import Chart from 'chart.js';

const styles = {
    height: 350,
};

class HomePage extends React.Component {
    componentDidMount() {
        this.getChartData();
    }

    getChartData() {
        $.get('/v1/demo/grants/2015')
            .success(grants => this.chart(grants))
            .error(error => console.log(error));
    }

    grantRow(grant, index) {
        return <div key={index}>{grant.name}</div>;
    }

    chart(data) {
        const chartData = {
            labels: ['Jan', 'Feb', 'Mar',
                     'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep',
                     'Oct', 'Nov', 'Dec'],
            datasets: [],
        };

        const funders = _.uniq(_.pluck(data, 'funder'));
        _.each(funders, (funder, index) => {
            const monthCounts = _.chain(data)
                            .where({ funder })
                            .map(grant => ({
                                award_date: parseInt(grant.award_date.slice(5, -3), 10),
                            }))
                            .countBy('award_date')
                            .value();

            const monthsOfYear = _.object(_.range(1, 13), _.times(12, _.random.bind(_, 0, 0)));
            const months = _.toArray(Object.assign({}, monthsOfYear, monthCounts));
            const colours = ['255, 99, 132', '54, 162, 235', '255, 206, 86'];

            return chartData.datasets.push({
                label: funder,
                data: months,
                backgroundColor: `rgba(${colours[index]}, 0.2)`,
                borderColor: `rgba(${colours[index]}, 1)`,
                borderWidth: 1,
            });
        });

        return new Chart(document.getElementById('chart'), {
            type: 'bar',
            data: chartData,
            options: {
                title: {
                    display: true,
                    text: `${_.uniq(_.pluck(data, 'year'))[0]} Grants`,
                },
                tooltips: {
                    mode: 'label',
                    multiKeyBackground: 'transparent',
                },
                scales: {
                    yAxes: [{
                        scaleLabel: {
                            display: true,
                            labelString: 'No. of grants',
                        },
                        ticks: {
                            beginAtZero: true,
                        },
                    }],
                },
            },
        });
    }

    render() {
        const { grants } = this.props;

        return (
          <div>
            <FunderList grants={grants} />
            <canvas id="chart" style={styles}></canvas>
          </div>
        );
    }
}

HomePage.propTypes = {
    grants: PropTypes.array.isRequired,
    actions: PropTypes.object.isRequired,
};

function mapStateToProps(state, ownProps) {
    return {
        grants: state.grants,
    };
}

function mapDispatchToProps(dispatch) {
    return {
        actions: bindActionCreators(grantActions, dispatch),
    };
}

export default connect(mapStateToProps, mapDispatchToProps)(HomePage);
