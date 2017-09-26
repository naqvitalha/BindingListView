import React, {Component} from 'react';
import {
    AppRegistry,
    StyleSheet,
    Text,
    View,
    Image,
    Dimensions
} from 'react-native';
import _ from 'lodash';

import {DataProvider, LayoutProvider, RecyclerListView} from "recyclerlistview";

const {width} = Dimensions.get("window");

const images = [
    'https://i.imgur.com/GCBVgXDb.jpg',
    'https://i.imgur.com/EXQVxqQb.jpg',
    'https://i.imgur.com/zADtGy9b.jpg',
    'https://i.imgur.com/EZDQNshb.jpg',
    'https://i.imgur.com/Jvh1OQmb.jpg',
    'https://i.imgur.com/tqZm14Rb.jpg',
    'https://i.imgur.com/9NltrAUb.jpg',
    'https://i.imgur.com/t6X0wXBb.jpg',
    'https://i.imgur.com/w7L7Rdkb.jpg',
    'https://i.imgur.com/JhkYX7Ob.jpg'
];

const names = require('./names.json');
const contacts = [];
for (let i = 0; i < 5000; i++) {
    const first = _.sample(names);
    const last = _.sample(names);
    contacts.push({
        name: `${first} ${last}`,
        initials: `${first.charAt(0)}${last.charAt(0)}`,
        image: [{uri: images[i % 10]}]
    });
}

export default class App extends Component {
    constructor(props) {
        super(props);
        this._dataProvider = new DataProvider((r1, r2) => {
            return r1 !== r2
        }).cloneWithRows(contacts);
        this._layoutProvider = new LayoutProvider((index) => {
                return 1;
            },
            (type, dim) => {
                dim.height = 71;
                dim.width = width;
            })
    }

    _rowRenderer = (type, data) => {
        debugger;
        return this.renderItemTemplate_withImages(data);
    };

    render() {
        return (
            <View style={styles.container}>
              <RecyclerListView style={{flex: 1}}
                                dataProvider={this._dataProvider}
                                layoutProvider={this._layoutProvider}
                                rowRenderer={this._rowRenderer}/>
            </View>
        );
    }

    renderItemTemplate_withImages(data) {
        return (
            <View style={styles.rowBody}>
              <Image
                  style={styles.initialsCircle}
                  source={{uri: data.image[0].uri}}/>
              <Text
                  style={styles.name}>{data.name}</Text>
            </View>
        );
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#F5FCFF',
    },
    rowBody: {
        flexDirection: 'row',
        alignItems: 'center',
        padding: 10,
        borderBottomWidth: 1,
        borderColor: '#cccccc',
        backgroundColor: 'white'
    },
    initialsCircle: {
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: '#49bed8',
        borderRadius: 25,
        width: 50,
        height: 50,
        marginRight: 15
    },
    imageCircle: {
        width: 50,
        height: 50
    },
    initials: {
        color: 'white',
        fontSize: 20,
        textAlign: 'center'
    },
    name: {
        fontSize: 20,
        backgroundColor: 'white',
        flex: 1
    }
});

AppRegistry.registerComponent('BindingListView', () => App);
